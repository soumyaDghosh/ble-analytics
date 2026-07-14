from django.contrib.auth.views import LoginView, LogoutView
from django.urls import path

from . import api, views

urlpatterns = [
    # Mobile JSON
    path('api/v1/cache/version', api.cache_version),
    path('api/v1/data/sync', api.data_sync),
    path('api/v1/location/batch', api.location_batch),

    # Auth
    path('setup/', views.setup, name='setup'),
    path('login/', LoginView.as_view(template_name='login.html'), name='login'),
    path('logout/', LogoutView.as_view(), name='logout'),
    path('signup/', views.signup, name='signup'),

    # Dashboard
    path('mall/', views.mall_settings, name='mall_setup'),
    path('', views.overview, name='dashboard'),
    path('heatmap/', views.heatmap, name='heatmap'),

    path('campaigns/', views.campaigns, name='campaigns'),
    path('stores/<int:store_id>/campaigns/new', views.campaign_edit, name='campaign_new'),
    path('stores/<int:store_id>/campaigns/<int:pk>', views.campaign_edit, name='campaign_edit'),
    path('stores/<int:store_id>/campaigns/<int:pk>/delete', views.campaign_delete, name='campaign_delete'),

    path('floors/', views.floors, name='floors'),
    path('floors/new', views.floor_edit, name='floor_new'),
    path('floors/<int:pk>/edit', views.floor_edit, name='floor_edit'),

    path('stores/', views.stores, name='stores'),
    path('stores/new', views.store_edit, name='store_new'),
    path('stores/<int:pk>/edit', views.store_edit, name='store_edit'),

    path('beacons/', views.beacons, name='beacons'),
    path('beacons/new', views.beacon_edit, name='beacon_new'),
    path('beacons/<int:pk>/edit', views.beacon_edit, name='beacon_edit'),

    path('keepers/', views.keepers, name='keepers'),
    path('keepers/<int:pk>/<str:action>', views.keeper_action, name='keeper_action'),
]
