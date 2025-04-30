from datetime import datetime

from sqlalchemy import (
    Column, Integer, String, Boolean, DateTime, JSON, ForeignKey, Index, event
)
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from ..db import Base

class SystemSettingDB(Base):
    __tablename__ = "systemsetting"

    setting_id = Column(
        Integer,
        primary_key=True,
        autoincrement=True
    )  # Primary key
    key = Column(
        String(100),
        unique=True,
        nullable=False
    )  # Setting name/key
    value = Column(
        JSON,
        nullable=True
    )  # JSON value of the setting
    is_active = Column(
        Boolean,
        default=True,
        nullable=False
    )  # Whether the setting is active
    created_at = Column(
        DateTime,
        server_default=func.now(),
        nullable=False
    )
    updated_at = Column(
        DateTime,
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False
    )
    # Reference to the user who last updated this setting
    updated_by_user_id = Column(
        Integer,
        ForeignKey("users.user_id", ondelete="SET NULL"),
        nullable=True
    )

    __table_args__ = (
        Index("idx_systemsetting_is_active", "is_active"),
    )

    # Relationship to UserDB
    updated_by_user = relationship(
        "UserDB",
        back_populates="system_settings",
        foreign_keys=[updated_by_user_id]
    )

# Event listener to update 'updated_at' timestamp before updates
@event.listens_for(SystemSettingDB, 'before_update')
def _update_timestamp(mapper, connection, target):
    target.updated_at = datetime.utcnow()
