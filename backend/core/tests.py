import unittest
from datetime import datetime, timedelta

from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse

from .dwell import GAP_S, _bucket, _session_splits
from .models import CacheVersion, Mall


class DwellLogic(unittest.TestCase):
    """Pure gaps-and-islands logic - no DB, runs under `manage.py test core`."""

    def test_bucket_edges(self):
        cases = [(0, 'glance'), (14, 'glance'), (15, 'look'), (59, 'look'),
                 (60, 'browse'), (299, 'browse'), (300, 'linger'), (10000, 'linger')]
        for sec, name in cases:
            self.assertEqual(_bucket(sec), name, sec)

    def test_session_splits_on_gap(self):
        t0 = datetime(2026, 1, 1, 12, 0, 0)
        secs = [0, 30, 30 + GAP_S + 1, 30 + GAP_S + 20]  # gap #3 > 5min → new session
        rows = [{'time': t0 + timedelta(seconds=s)} for s in secs]
        self.assertEqual(list(_session_splits(rows)), [(0, 1), (2, 3)])
        self.assertEqual(list(_session_splits(rows[:1])), [(0, 0)])  # single ping


class MallSetupGate(TestCase):
    """Fresh install (no mall) funnels admins to setup and creates a pinned id=1."""

    def setUp(self):
        User = get_user_model()
        self.admin = User.objects.create_superuser('admin', password='x')
        self.keeper = User.objects.create_user('nike', password='x')

    def test_admin_gated_to_setup_then_creates_pinned_mall(self):
        self.client.force_login(self.admin)
        # no mall → dashboard bounces to the setup page
        self.assertRedirects(self.client.get(reverse('dashboard')),
                             reverse('mall_setup'), fetch_redirect_response=False)
        # setup page itself renders the create form
        self.assertEqual(self.client.get(reverse('mall_setup')).status_code, 200)
        # create → mall exists, pinned to id=1, and lands on the dashboard
        r = self.client.post(reverse('mall_setup'), {'name': 'City Center', 'address': ''})
        self.assertRedirects(r, reverse('dashboard'), fetch_redirect_response=False)
        self.assertEqual(Mall.objects.get().id, 1)
        # every mall needs its cache row from birth or the app's version poll 404s
        self.assertTrue(CacheVersion.objects.filter(mall_id=1).exists())
        # gate now lets the dashboard through
        self.assertEqual(self.client.get(reverse('dashboard')).status_code, 200)

    def test_keeper_sees_wait_screen_not_the_form(self):
        self.client.force_login(self.keeper)
        r = self.client.get(reverse('mall_setup'))
        self.assertContains(r, 'hasn')       # "hasn't been set up yet"
        self.assertNotContains(r, '<form method="post" class="max-w-md')


class SignupApproval(TestCase):
    """Self-registered keeper lands inactive; admin approval flips is_active."""

    PW = 'S3curePass!x'

    def test_signup_inactive_then_admin_approves(self):
        r = self.client.post(reverse('signup'), {
            'username': 'bob', 'shop_name': 'Bob Cafe',
            'password1': self.PW, 'password2': self.PW})
        self.assertEqual(r.status_code, 200)
        u = get_user_model().objects.get(username='bob')
        self.assertFalse(u.is_active)                 # can't log in yet
        self.assertEqual(u.first_name, 'Bob Cafe')    # shop-name hint stored
        self.assertFalse(self.client.login(username='bob', password=self.PW))
        # admin approves (mall must exist or the setup gate intercepts)
        Mall.objects.create(id=1, name='M')
        self.client.force_login(get_user_model().objects.create_superuser('admin', password='x'))
        self.client.post(reverse('keeper_action', args=[u.id, 'approve']))
        u.refresh_from_db()
        self.assertTrue(u.is_active)
        self.assertTrue(self.client.login(username='bob', password=self.PW))


class CampaignAccess(TestCase):
    """Campaigns belong to keepers - admins are 403'd out."""

    def test_admin_403_keeper_200(self):
        User = get_user_model()
        Mall.objects.create(id=1, name='M')  # else the setup gate redirects first
        admin = User.objects.create_superuser('admin', password='x')
        keeper = User.objects.create_user('nike', password='x')  # active by default
        self.client.force_login(admin)
        self.assertEqual(self.client.get(reverse('campaigns')).status_code, 403)
        self.client.force_login(keeper)
        self.assertEqual(self.client.get(reverse('campaigns')).status_code, 200)


class FormFields(TestCase):
    def test_store_form_exposes_image(self):
        from .forms import StoreForm
        self.assertIn('image', StoreForm().fields)

    def test_new_campaign_form_has_date_defaults(self):
        from .forms import CampaignForm
        f = CampaignForm()
        self.assertIsNotNone(f.fields['starts_at'].initial)
        self.assertIn('min', f.fields['starts_at'].widget.attrs)

    def test_campaign_rejects_end_before_start(self):
        from .forms import CampaignForm
        bad = CampaignForm(data={'title': 'T', 'body': 'B', 'status': 'draft',
                                 'starts_at': '2026-07-10T10:00', 'ends_at': '2026-07-09T10:00'})
        self.assertFalse(bad.is_valid())
        self.assertIn('ends_at', bad.errors)
