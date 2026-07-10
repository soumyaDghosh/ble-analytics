from .models import Floor, Mall


def dashboard(request):
    """Mall/floors/role available on every dashboard page (used by the shell)."""
    if not request.user.is_authenticated:
        return {}
    mall = Mall.objects.first()
    return {
        'mall': mall,
        'nav_floors': Floor.objects.filter(mall=mall) if mall else [],
        'is_admin': request.user.is_superuser,
    }
