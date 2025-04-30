from sqlalchemy import Column, Integer, String, Numeric, Date, Index, ForeignKey
from sqlalchemy.dialects.postgresql import JSON, TIMESTAMP
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from final_project.db import Base

# Model for admin statistics records
class AdminStatisticsDB(Base):
    __tablename__ = "admin_statistics"

    stat_id = Column(Integer, primary_key=True, autoincrement=True)  # Primary Key
    stat_type = Column(String(50), nullable=False)  # Type of statistic (e.g., 'ai_usage', 'user_growth')
    aggregate_value = Column(Numeric, nullable=False)  # Aggregated value (e.g., total AI requests)
    user_count = Column(Integer, nullable=False)  # Related user count
    date = Column(Date, nullable=False)  # Date of the statistic
    additional_data = Column(JSON)  # Additional data (JSON format)
    ai_usage_metrics = Column(JSON)  # AI usage metrics (JSON format)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())  # Creation timestamp

    admin_id = Column(Integer, ForeignKey("admins.admin_id"), nullable=True)  # Optional link to Admin
    admin = relationship("AdminDB", back_populates="statistics")  # Relationship with AdminDB

    __table_args__ = (
        Index("idx_admin_statistics_date", "date"),  # Index for date
        Index("idx_admin_statistics_stat_type", "stat_type"),  # Index for stat_type
    )
