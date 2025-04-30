import os
import secrets
from dynaconf import Dynaconf

# ✨ Select the path for this folder (config.py)
HERE = os.path.dirname(os.path.abspath(__file__))

# Download default settings using Dynaconf
settings = Dynaconf(
    envvar_prefix="final_project",
    preload=[os.path.join(HERE, "default.toml")],
    settings_files=[
        os.path.join(HERE, "settings.toml"),
        os.path.join(HERE, ".secrets.toml")
    ],
    environments=["development", "production", "testing"],
    env_switcher="final_project_env",
    load_dotenv=True,
)

# ✅ Get security key from environment or generate a secure one
if not settings.get("security.secret_key"):
    # First try to get from environment variable
    secret_key = os.environ.get("FINAL_PROJECT_SECRET_KEY")
    
    # If not available, generate a secure random key (32 bytes / 256 bits)
    if not secret_key:
        secret_key = secrets.token_hex(32)
        print("⚠️ WARNING: Using auto-generated secret key. For production, set FINAL_PROJECT_SECRET_KEY env variable.")
    
    # Set the secret key in settings
    settings.security.secret_key = secret_key

# ✅ AI settings separately after settings loaded
settings.ai = {
    "api_key": settings.get("AI_API_KEY"),
    "api_url": settings.get("AI_API_URL"),
}

"""
# How to use the config.py file in the project:

from final_project.config import settings

## Accessing values:
settings.SECRET_KEY
settings.db.uri
settings["db.uri"]
settings.get("DB__uri")

## To change a variable in settings.toml:
[development]
DEBUG=true

## As an environment variable:
export final_project_DEBUG=true

## To change the environment:
final_project_ENV=production uvicorn final_project.main:app

For more information:
https://dynaconf.com
"""