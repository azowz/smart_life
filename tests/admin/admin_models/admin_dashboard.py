from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, Index, event
from sqlalchemy.dialects.postgresql import JSON, TIMESTAMP
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship, object_session
from final_project.db import Base

# Model for admin dashboards
class AdminDashboardDB(Base):
    __tablename__ = "admin_dashboards"

    dashboard_id = Column(Integer, primary_key=True, autoincrement=True)  # Primary key
    admin_id = Column(Integer, ForeignKey("admins.admin_id", ondelete="CASCADE"), nullable=False)  # Link to admin
    layout = Column(JSON, default={})  # Dashboard layout configuration (JSON)
    widgets = Column(JSON, default=[])  # List of widgets (JSON array)
    name = Column(String(100), nullable=False)  # Dashboard name
    is_default = Column(Boolean, default=False)  # Is this the default dashboard?
    ai_insights_enabled = Column(Boolean, default=True)  # AI insights flag
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())  # Creation timestamp
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now())  # Last updated timestamp

    __table_args__ = (
        Index("idx_admin_dashboards_admin_id", "admin_id"),  # Index for admin_id
        {'extend_existing': True}  # Allow table redefinition if it exists
    )

    # Relationship with AdminDB
    admin = relationship("AdminDB", back_populates="dashboards")

# Listener to update 'updated_at' timestamp on update
@event.listens_for(AdminDashboardDB, 'before_update')
def receive_before_update(mapper, connection, target):
    target.updated_at = func.now()

# Listener to ensure only one default dashboard per admin
@event.listens_for(AdminDashboardDB, 'before_insert')
@event.listens_for(AdminDashboardDB, 'before_update')
def ensure_single_default_dashboard(mapper, connection, target):
    if target.is_default:
        session = object_session(target)
        if session:
            # Unset other dashboards as default for the same admin
            session.query(AdminDashboardDB).filter(
                AdminDashboardDB.admin_id == target.admin_id,
                AdminDashboardDB.dashboard_id != target.dashboard_id,
                AdminDashboardDB.is_default == True
            ).update({"is_default": False})
