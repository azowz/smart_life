from typing import List, Dict, Any, Optional

from ...models import AdminDashboardDB
from ...schemas import AdminDashboardCreate, AdminDashboardUpdate

def create_dashboard(db_session, dashboard_data: AdminDashboardCreate):
    """
    Create a new admin dashboard
    
    Args:
        db_session: SQLAlchemy database session
        dashboard_data: Dashboard data
        
    Returns:
        The created dashboard
    """
    db_dashboard = AdminDashboardDB(**dashboard_data.dict())
    db_session.add(db_dashboard)
    db_session.commit()
    db_session.refresh(db_dashboard)
    return db_dashboard

def update_dashboard(db_session, dashboard_id: int, dashboard_data: AdminDashboardUpdate):
    """
    Update an existing dashboard
    
    Args:
        db_session: SQLAlchemy database session
        dashboard_id: ID of the dashboard to update
        dashboard_data: Dashboard update data
        
    Returns:
        The updated dashboard or None if not found
    """
    db_dashboard = db_session.query(AdminDashboardDB).filter(
        AdminDashboardDB.dashboard_id == dashboard_id
    ).first()
    
    if not db_dashboard:
        return None
    
    # Update only the fields that are provided
    update_data = dashboard_data.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_dashboard, key, value)
    
    db_session.commit()
    db_session.refresh(db_dashboard)
    return db_dashboard

def get_dashboard(db_session, dashboard_id: int):
    """
    Get a dashboard by ID
    
    Args:
        db_session: SQLAlchemy database session
        dashboard_id: The dashboard ID
        
    Returns:
        The dashboard or None if not found
    """
    return db_session.query(AdminDashboardDB).filter(
        AdminDashboardDB.dashboard_id == dashboard_id
    ).first()

def get_admin_dashboards(db_session, admin_id: int) -> List[AdminDashboardDB]:
    """
    Get all dashboards for a specific admin
    
    Args:
        db_session: SQLAlchemy database session
        admin_id: The admin ID
        
    Returns:
        List of dashboards
    """
    return db_session.query(AdminDashboardDB).filter(
        AdminDashboardDB.admin_id == admin_id
    ).order_by(
        AdminDashboardDB.is_default.desc(),
        AdminDashboardDB.name
    ).all()

def get_default_dashboard(db_session, admin_id: int) -> Optional[AdminDashboardDB]:
    """
    Get the default dashboard for a specific admin
    
    Args:
        db_session: SQLAlchemy database session
        admin_id: The admin ID
        
    Returns:
        The default dashboard or None if not found
    """
    return db_session.query(AdminDashboardDB).filter(
        AdminDashboardDB.admin_id == admin_id,
        AdminDashboardDB.is_default == True
    ).first()

def add_widget_to_dashboard(db_session, dashboard_id: int, widget_data: Dict[str, Any]):
    """
    Add a widget to a dashboard
    
    Args:
        db_session: SQLAlchemy database session
        dashboard_id: ID of the dashboard
        widget_data: Widget data
        
    Returns:
        The updated dashboard or None if not found
    """
    db_dashboard = db_session.query(AdminDashboardDB).filter(
        AdminDashboardDB.dashboard_id == dashboard_id
    ).first()
    
    if not db_dashboard:
        return None
    
    # Add the widget to the existing widgets
    current_widgets = db_dashboard.widgets or []
    current_widgets.append(widget_data)
    db_dashboard.widgets = current_widgets
    
    db_session.commit()
    db_session.refresh(db_dashboard)
    return db_dashboard

def remove_widget_from_dashboard(db_session, dashboard_id: int, widget_index: int):
    """
    Remove a widget from a dashboard
    
    Args:
        db_session: SQLAlchemy database session
        dashboard_id: ID of the dashboard
        widget_index: Index of the widget to remove
        
    Returns:
        The updated dashboard or None if not found or index out of range
    """
    db_dashboard = db_session.query(AdminDashboardDB).filter(
        AdminDashboardDB.dashboard_id == dashboard_id
    ).first()
    
    if not db_dashboard:
        return None
    
    # Remove the widget if the index is valid
    current_widgets = db_dashboard.widgets or []
    if 0 <= widget_index < len(current_widgets):
        del current_widgets[widget_index]
        db_dashboard.widgets = current_widgets
        
        db_session.commit()
        db_session.refresh(db_dashboard)
        return db_dashboard
    else:
        return None

def delete_dashboard(db_session, dashboard_id: int):
    """
    Delete a dashboard
    
    Args:
        db_session: SQLAlchemy database session
        dashboard_id: ID of the dashboard to delete
        
    Returns:
        True if dashboard was deleted, False if not found
    """
    dashboard = db_session.query(AdminDashboardDB).filter(
        AdminDashboardDB.dashboard_id == dashboard_id
    ).first()
    
    if not dashboard:
        return False
    
    db_session.delete(dashboard)
    db_session.commit()
    return True