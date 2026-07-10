import json
from datetime import timedelta

from django import forms
from django.contrib.auth import get_user_model
from django.contrib.auth.forms import UserCreationForm
from django.db.models import Q
from django.utils import timezone

from .models import Beacon, Campaign, Floor, Mall, Store

INPUT = ('w-full rounded-md border border-line bg-surface px-3 py-2 font-sans text-sm '
         'text-ink placeholder:text-muted focus:border-signal focus:outline-none '
         'focus:ring-2 focus:ring-signal/20')


class Styled(forms.ModelForm):
    """Apply the wayfinding input style to every widget, no per-field clutter."""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for f in self.fields.values():
            w = f.widget
            if isinstance(w, (forms.CheckboxSelectMultiple, forms.CheckboxInput, forms.RadioSelect)):
                continue
            w.attrs['class'] = (w.attrs.get('class', '') + ' ' + INPUT).strip()


class MallForm(Styled):
    # Top of the hierarchy — a fresh install creates this before anything else.
    class Meta:
        model = Mall
        fields = ['name', 'address']
        widgets = {'address': forms.TextInput(attrs={'placeholder': 'Street / area (optional)'})}


class CampaignForm(Styled):
    class Meta:
        model = Campaign
        fields = ['title', 'body', 'image', 'coupon', 'discount',
                  'starts_at', 'ends_at', 'status', 'target_beacons']
        widgets = {
            'body': forms.Textarea(attrs={'rows': 2}),
            'starts_at': forms.DateTimeInput(attrs={'type': 'datetime-local'}, format='%Y-%m-%dT%H:%M'),
            'ends_at': forms.DateTimeInput(attrs={'type': 'datetime-local'}, format='%Y-%m-%dT%H:%M'),
            'target_beacons': forms.CheckboxSelectMultiple,
        }

    def __init__(self, *args, store=None, **kwargs):
        super().__init__(*args, **kwargs)
        for name in ('starts_at', 'ends_at'):
            self.fields[name].input_formats = ['%Y-%m-%dT%H:%M']
        if store is not None:  # only this store's beacons can trigger its campaign
            self.fields['target_beacons'].queryset = store.beacons.all()
        # New campaign: sensible window (now → +7d) so the picker isn't blank, and
        # the native input can't select the past. Edits keep their saved values.
        if not self.instance.pk:
            now = timezone.localtime()
            self.fields['starts_at'].initial = now
            self.fields['ends_at'].initial = now + timedelta(days=7)
            stamp = now.strftime('%Y-%m-%dT%H:%M')
            self.fields['starts_at'].widget.attrs['min'] = stamp
            self.fields['ends_at'].widget.attrs['min'] = stamp

    def clean(self):
        c = super().clean()
        s, e = c.get('starts_at'), c.get('ends_at')
        if s and e and e <= s:
            self.add_error('ends_at', 'Ends must be after Starts.')
        return c


class StoreForm(Styled):
    # Footprint polygon, carried as JSON text in a hidden field the draw tool writes.
    # A plain CharField (not the model JSONField) keeps the widget round-trip simple.
    shape_json = forms.CharField(widget=forms.HiddenInput, required=False)
    # The store owns beacon assignment (reverse FK). Offer beacons that are
    # unassigned or already ours — never silently steal another store's beacon.
    beacons = forms.ModelMultipleChoiceField(
        queryset=Beacon.objects.none(), required=False,
        widget=forms.CheckboxSelectMultiple)

    class Meta:
        model = Store
        fields = ['name', 'category', 'image', 'floor', 'keeper', 'pos_x', 'pos_y']
        widgets = {'pos_x': forms.HiddenInput(), 'pos_y': forms.HiddenInput()}

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Assign to any approved storekeeper account; a keeper holds many stores (FK).
        self.fields['keeper'].queryset = get_user_model().objects.filter(
            is_superuser=False, is_active=True)
        self.fields['keeper'].empty_label = '— unassigned —'

        inst = self.instance if self.instance.pk else None
        qs = Beacon.objects.filter(Q(store__isnull=True) | Q(store=inst)) if inst \
            else Beacon.objects.filter(store__isnull=True)
        if inst and inst.floor_id:
            qs = qs.filter(floor_id=inst.floor_id)
        self.fields['beacons'].queryset = qs.order_by('adv_id')
        if inst:
            self.fields['beacons'].initial = inst.beacons.all()
            if inst.shape:
                self.fields['shape_json'].initial = json.dumps(inst.shape)

    def clean_shape_json(self):
        raw = (self.cleaned_data.get('shape_json') or '').strip()
        if not raw:
            return None
        try:
            pts = json.loads(raw)
        except ValueError:
            raise forms.ValidationError('Invalid footprint data — redraw it.')
        if not isinstance(pts, list) or len(pts) < 3:
            raise forms.ValidationError('Draw at least 3 points, or clear the footprint.')
        return [[int(p[0]), int(p[1])] for p in pts]

    def clean(self):
        c = super().clean()
        if not self.instance.pk and not c.get('shape_json'):
            raise forms.ValidationError('Draw the store footprint on the plan first.')
        return c


class FloorForm(Styled):
    # Boundary polygon carried as JSON text; the graph-paper tool writes it.
    outline_json = forms.CharField(widget=forms.HiddenInput, required=False)

    class Meta:
        model = Floor
        fields = ['name', 'number', 'width_m', 'height_m']

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['width_m'].required = True
        self.fields['height_m'].required = True
        self.fields['width_m'].label = 'Width (m)'
        self.fields['height_m'].label = 'Height (m)'
        if self.instance.pk and self.instance.outline:
            self.fields['outline_json'].initial = json.dumps(self.instance.outline)

    def clean_outline_json(self):
        raw = (self.cleaned_data.get('outline_json') or '').strip()
        if not raw:
            return None
        try:
            pts = json.loads(raw)
        except ValueError:
            raise forms.ValidationError('Invalid boundary data — redraw it.')
        if not isinstance(pts, list) or len(pts) < 3:
            raise forms.ValidationError('Draw at least 3 points, or clear the boundary.')
        return [[int(p[0]), int(p[1])] for p in pts]


class BeaconForm(Styled):
    class Meta:
        model = Beacon
        # No 'store' — assignment lives on the store form (store owns its beacons).
        fields = ['adv_id', 'beacon_type', 'floor', 'tx_power', 'pos_x', 'pos_y']
        widgets = {'pos_x': forms.HiddenInput(), 'pos_y': forms.HiddenInput()}


class SignupForm(UserCreationForm):
    """Public storekeeper self-registration. Lands inactive — an admin approves
    (flips is_active) on the Keepers page and assigns the actual Store afterward."""
    shop_name = forms.CharField(
        max_length=120, label='Shop / business name',
        help_text='So the admin knows which store to hand you.')

    class Meta(UserCreationForm.Meta):
        model = get_user_model()
        fields = ['username']

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for f in self.fields.values():
            f.widget.attrs['class'] = (f.widget.attrs.get('class', '') + ' ' + INPUT).strip()

    def save(self, commit=True):
        user = super().save(commit=False)
        # ponytail: reuse User.first_name as the signup shop-name hint — no extra
        # model/migration for one label the admin only reads before assigning a store.
        user.first_name = self.cleaned_data['shop_name']
        user.is_active = False   # gated on admin approval before first login
        user.is_staff = user.is_superuser = False
        if commit:
            user.save()
        return user
