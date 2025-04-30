from datetime import datetime

from sqlalchemy import (
    Column, Integer, String, Text, Boolean, DateTime,
    Numeric, ForeignKey, Index, event
)
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from ..db import Base

class ConfigurationDB(Base):
    __tablename__ = "configuration"

    config_id = Column(
        Integer,
        primary_key=True,
        autoincrement=True
    )  # Primary key
    api_key = Column(
        Text,
        nullable=False
    )  # AI API key
    model_version = Column(
        String(100),
        nullable=False
    )  # AI model version
    endpoint_url = Column(
        Text,
        nullable=False
    )  # API endpoint URL
    request_timeout = Column(
        Integer,
        default=30,
        nullable=False
    )  # Request timeout (seconds)
    max_tokens = Column(
        Integer,
        default=2048,
        nullable=False
    )  # Max tokens per request
    temperature = Column(
        Numeric(3, 2),
        default=0.7,
        nullable=False
    )  # Sampling temperature
    is_active = Column(
        Boolean,
        default=False,
        nullable=False
    )  # Whether this config is active

    # Reference to the user who last updated this configuration
    updated_by_user_id = Column(
        Integer,
        ForeignKey("users.user_id", ondelete="SET NULL"),
        nullable=True
    )
    updated_at = Column(
        DateTime,
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False
    )  # Last updated timestamp

    __table_args__ = (
        Index("idx_configuration_is_active", "is_active"),
    )

    # Relationship to UserDB
    user = relationship(
        "UserDB",
        back_populates="configurations",
        foreign_keys=[updated_by_user_id]
    )

# Event listener to update 'updated_at' timestamp before updates
@event.listens_for(ConfigurationDB, 'before_update')
def _update_timestamp(mapper, connection, target):
    target.updated_at = datetime.utcnow()