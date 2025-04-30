from datetime import datetime
from typing import Optional, List, Union

from pydantic import BaseModel, Extra
from sqlalchemy import Column, Integer, String, Boolean, Text, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from final_project.db import Base  # استخدام Base من SQLAlchemy

# ✅ SQLAlchemy Model
class ContentDB(Base):
    __tablename__ = "content"

    id = Column(Integer, primary_key=True, autoincrement=True)
    title = Column(String(255), nullable=False)
    slug = Column(String(255), nullable=True)
    text = Column(Text, nullable=False)
    published = Column(Boolean, default=False)
    created_time = Column(DateTime, default=datetime.utcnow)
    tags = Column(String, default="")  # Stored as comma-separated string
    user_id = Column(Integer, ForeignKey("users.user_id"))

    # Relationship with UserDB
    user = relationship("UserDB", back_populates="contents")

# ✅ Pydantic Schema for API Response
class ContentResponse(BaseModel):
    id: int
    title: str
    slug: Optional[str]
    text: str
    published: bool
    created_time: datetime
    tags: List[str]
    user_id: int

    def __init__(self, **kwargs):
        tags = kwargs.pop("tags", "")
        if isinstance(tags, str):
            kwargs["tags"] = tags.split(",") if tags else []
        super().__init__(**kwargs)

# ✅ Pydantic Schema for incoming data
class ContentIncoming(BaseModel):
    title: Optional[str]
    text: Optional[str]
    published: Optional[bool] = False
    tags: Optional[Union[List[str], str]] = []
    slug: Optional[str] = None

    class Config:
        extra = Extra.allow
        arbitrary_types_allowed = True

    def __init__(self, **kwargs):
        tags = kwargs.pop("tags", [])
        if isinstance(tags, list):
            kwargs["tags"] = ",".join(tags)
        super().__init__(**kwargs)
        self.generate_slug()

    def generate_slug(self):
        if not self.slug and self.title:
            object.__setattr__(self, 'slug', self.title.lower().replace(" ", "-"))
