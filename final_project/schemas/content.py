from datetime import datetime
from typing import List, Optional, Union

from pydantic import BaseModel, root_validator


# ✅ MODEL used for (POST / PATCH)
class ContentIncoming(BaseModel):
    title: Optional[str]
    text: Optional[str]
    published: Optional[bool] = False
    tags: Optional[Union[List[str], str]] = []

    @root_validator(pre=True)
    def join_tags(cls, values):
        tags = values.get("tags")
        if isinstance(tags, list):
            values["tags"] = ",".join(tag.strip() for tag in tags)
        return values

    class Config:
        orm_mode = True
 

# ✅model used (GET / تفاصيل)
class ContentResponse(BaseModel):
    id: int
    title: str
    slug: Optional[str]
    text: str
    published: bool
    created_time: datetime
    tags: List[str]
    user_id: int

    @root_validator(pre=True)
    def split_tags(cls, values):
        tags = values.get("tags")
        if isinstance(tags, str):
            values["tags"] = [tag.strip() for tag in tags.split(",") if tag.strip()]
        return values


    model_config = {
        "from_attributes": True  # Replaces orm_mode in Pydantic v2
    }