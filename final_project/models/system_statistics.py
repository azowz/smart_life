from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, Index, Numeric, Date, DateTime
from sqlalchemy.dialects.postgresql import TIMESTAMP, JSON
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from final_project.db import Base

# SQLAlchemy model for system statistics
class SystemStatisticsDB(Base):
    __tablename__ = "system_statistics"

    stat_id = Column(Integer, primary_key=True, autoincrement=True)  # Primary key
    stat_type = Column(String(50), nullable=False)  # Type of statistic (e.g., "usage", "performance")
    aggregate_value = Column(Numeric)  # Aggregated value (e.g., total usage)
    user_count = Column(Integer)  # Number of users
    date = Column(Date, nullable=False)  # Date of the statistic
    additional_data = Column(JSON)  # Optional additional data in JSON format
    ai_usage_metrics = Column(JSON)  # AI usage metrics in JSON format
    created_at = Column(DateTime, server_default=func.now())  # Creation timestamp

    __table_args__ = (
        Index("idx_system_statistics_stat_type", "stat_type"),  # Index on stat_type
        Index("idx_system_statistics_date", "date"),  # Index on date
    )
