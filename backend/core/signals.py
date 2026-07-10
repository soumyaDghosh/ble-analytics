from django.db.models import F
from django.db.models.signals import m2m_changed, post_delete, post_save
from django.dispatch import receiver

from .models import Beacon, CacheVersion, Campaign, Floor, Store


def bump(mall_id):
    CacheVersion.objects.filter(mall_id=mall_id).update(version=F('version') + 1)


@receiver([post_save, post_delete], sender=Store)
@receiver([post_save, post_delete], sender=Beacon)
@receiver([post_save, post_delete], sender=Floor)
def _bump_direct(sender, instance, **kwargs):
    bump(instance.mall_id)


@receiver([post_save, post_delete], sender=Campaign)
def _bump_campaign(sender, instance, **kwargs):
    bump(instance.store.mall_id)


@receiver(m2m_changed, sender=Campaign.target_beacons.through)
def _bump_m2m(sender, instance, action, **kwargs):
    if action in ('post_add', 'post_remove', 'post_clear'):
        bump(instance.store.mall_id)
