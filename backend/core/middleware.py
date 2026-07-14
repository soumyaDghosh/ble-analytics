from django.conf import settings
from django.shortcuts import redirect
from django.urls import reverse

from .models import Mall


class NgrokCsrfTrust:
    """Dynamically trust ngrok tunnel origins for CSRF. Ngrok URLs are ephemeral
    and include a random subdomain, so static CSRF_TRUSTED_ORIGINS can't cover them."""

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        origin = request.META.get('HTTP_ORIGIN', '')
        if origin and 'ngrok' in origin:
            settings.CSRF_TRUSTED_ORIGINS = list(settings.CSRF_TRUSTED_ORIGINS) + [origin]
        return self.get_response(request)


class MallSetupGate:
    """A fresh install has no mall, but the whole single-mall app hinges on one
    existing (Mall.objects.first() everywhere). Until it's created, funnel
    authenticated dashboard traffic to the setup page. The mobile JSON API, auth,
    and static/media are left alone."""

    EXEMPT_PREFIXES = ('/api/', '/static/', '/media/')

    def __init__(self, get_response):
        self.get_response = get_response
        self.setup_url = reverse('mall_setup')
        self.logout_url = reverse('logout')
        self.seed_url = reverse('seed_demo')

    def __call__(self, request):
        user = getattr(request, 'user', None)
        if (user is not None and user.is_authenticated
                and not request.path.startswith(self.EXEMPT_PREFIXES)
                and request.path not in (self.setup_url, self.logout_url, self.seed_url)
                # ponytail: one cheap indexed exists() per gated page load; cache
                # it only if that ever shows up in a profile.
                and not Mall.objects.exists()):
            return redirect('mall_setup')
        return self.get_response(request)
