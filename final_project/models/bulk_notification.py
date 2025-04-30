from sqlalchemy import Column, Integer, String, Text, Boolean, ForeignKey, Index
from sqlalchemy.dialects.postgresql import JSON, TIMESTAMP
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from ..db import Base

class BulkNotificationDB(Base):
    __tablename__ = "bulk_notification"

    bulk_notification_id = Column(
        Integer,
        primary_key=True,
        autoincrement=True
    )  # Primary key
    title = Column(
        String(255),
        nullable=False
    )  # Notification title
    message = Column(
        Text,
        nullable=False
    )  # Notification message body

    # Reference to the user who created this notification
    created_by_user_id = Column(
        Integer,
        ForeignKey("users.user_id", ondelete="SET NULL"),
        nullable=False
    )

    created_at = Column(
        TIMESTAMP(timezone=True),
        server_default=func.now(),
        nullable=False
    )  # Creation timestamp
    sent_count = Column(
        Integer,
        default=0,
        nullable=False
    )  # Number of notifications sent
    is_scheduled = Column(
        Boolean,
        default=False,
        nullable=False
    )  # Whether this notification is scheduled
    schedule_time = Column(
        TIMESTAMP(timezone=True),
        nullable=True
    )  # Scheduled send time
    is_sent = Column(
        Boolean,
        default=False,
        nullable=False
    )  # Whether this notification has been sent
    target_criteria = Column(
        JSON,
        nullable=True
    )  # Target audience criteria

    # Indexes for performance
    __table_args__ = (
        Index(
            "idx_bulk_notification_created_by_user",
            "created_by_user_id"
        ),  # Index on created_by_user_id
        Index(
            "idx_bulk_notification_scheduled",
            "schedule_time",
            postgresql_where=(
                is_scheduled == True
            ) & (is_sent == False)
        ),  # Partial index for scheduled unsent notifications
    )

    # Relationship to UserDB
    user = relationship(
        "UserDB",
        back_populates="bulk_notifications"
    )