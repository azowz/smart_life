from fastapi import Depends
from sqlmodel import Session, SQLModel, create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from .config import settings

# ✅ Create database engine using settings
engine = create_engine(
    settings.db.uri,
    echo=settings.db.echo,
    connect_args=settings.db.connect_args,
)

# ✅ Define SQLAlchemy Base
Base = declarative_base()

# ✅ Function to create tables for SQLModel and SQLAlchemy together
def create_db_and_tables():
    SQLModel.metadata.create_all(engine)
    Base.metadata.create_all(bind=engine)

# ✅ Function to return the session (used with Depends)
def get_session():
    with Session(engine) as session:
        yield session

# ✅ Quick session dependency
ActiveSession = Depends(get_session)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
