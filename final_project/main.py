from fastapi import FastAPI
from sqlalchemy.orm import Session
from final_project.db import create_db_and_tables, engine
from final_project.models import UserDB, DefaultHabitDB
from final_project.schemas.user import UserCreate
from final_project.security import get_password_hash
from final_project.router import main_router

app = FastAPI(
    title="Smart Life Organizer API",
    description="API for managing tasks, habits, categories, and more",
    version="1.0.0"
)

# Include the main router with all endpoints
app.include_router(main_router)

# Root endpoint for health check
@app.get("/", tags=["Root"])
def root():
    return {"message": "Smart Life Organizer API is running 🚀"}

# Startup event for database initialization and data seeding
@app.on_event("startup")
def startup_event():
    create_db_and_tables()  # Create database tables if they don't exist

    #Uncomment this block to enable data seeding (users + default habits)
    with Session(engine) as session:
        
        #➕ Add default users
        users_data = [
            {"username": "moh", "email": "moh@example.com", "password": "UserPassword123!", "first_name": "Moh", "last_name": "User", "gender": "male"},
            {"username": "abdulaziz", "email": "abdulaziz@example.com", "password": "AbdulPassword123!", "first_name": "Abdulaziz", "last_name": "Hkeem", "gender": "male"},
            {"username": "azo", "email": "azo@example.com", "password": "a123123", "first_name": "Abdulaziz", "last_name": "Hkeem", "gender": "male"},
            {"username": "sull", "email": "sull@example.com", "password": "a123123", "first_name": "Suliman", "last_name": "Yos", "gender": "female"},
        ]
        users = []
        for user_info in users_data:
            user = session.query(UserDB).filter_by(username=user_info["username"]).first()
            if not user:
                user = UserDB(
                    username=user_info["username"],
                    email=user_info["email"],
                    password_hash=get_password_hash(user_info["password"]),
                    first_name=user_info["first_name"],
                    last_name=user_info["last_name"],
                    gender=user_info["gender"],
                    is_active=True,
                    superuser=True  # Mark as superuser
                )
                session.add(user)
                session.commit()
                session.refresh(user)
                print(f"✅ User '{user.username}' created")
            users.append(user)

        #➕ Add default habits for each user
        default_habits = [
            {"name": "Drink Water", "description": "Stay hydrated", "frequency": "daily"},
            {"name": "Training", "description": "Exercise regularly", "frequency": "daily"},
            {"name": "Study", "description": "Dedicate time for studying", "frequency": "daily"},
            {"name": "Journal", "description": "Write down your thoughts", "frequency": "daily"},
            {"name": "Read Books", "description": "Expand your knowledge", "frequency": "daily"},
            {"name": "Sleep", "description": "Get enough rest", "frequency": "daily"},
        ]
        for user in users:
            for habit in default_habits:
                exists = session.query(DefaultHabitDB).filter_by(
                    name=habit["name"],
                    created_by_user_id=user.user_id
                ).first()
                if not exists:
                    new_habit = DefaultHabitDB(
                        name=habit["name"],
                        description=habit["description"],
                        frequency=habit["frequency"],
                        is_active=True,
                        ai_recommended=True,
                        created_by_user_id=user.user_id
                    )
                    session.add(new_habit)
                    print(f"✅ Default habit '{habit['name']}' created for user '{user.username}'")
            session.commit()

#Run the app with Uvicorn
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("final_project.main:app", host="0.0.0.0", port=8000, reload=True)

# @app.post("/users/")
# def create_user(user: UserCreate):
#     # logic to create a user
#     # E.g., saving user to the database
#     return {"message": "User created successfully"}
#     UserPasssword123!