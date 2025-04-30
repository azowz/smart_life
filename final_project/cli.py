
import typer
import uvicorn
from sqlmodel import Session, select

from .app import app
from .config import settings
from .db import create_db_and_tables, engine
from .models.content import Content
from .security import User

cli = typer.Typer(name="final_project API")


@cli.command()                                                                     #can be used to create a command line interface (CLI) for your FastAPI application.              
def run(
    port: int = settings.server.port,                                              # default port from settings
    host: str = settings.server.host,                                              # default host from settings
    log_level: str = settings.server.log_level,                                    # default log level from settings
    reload: bool = settings.server.reload,                                         # default reload from settings
):                                                                                 # pragma: no cover
    """Run the API server."""
    uvicorn.run(
        "final_project.app:app",
        host=host,
        port=port,
        log_level=log_level,
        reload=reload,
    )


@cli.command()
def create_user(username: str, password: str, superuser: bool = False):                    
    """Create user"""
    create_db_and_tables(engine)                                                  # create the database and tables if they do not exist
    with Session(engine) as session:                                              # open and close the session automatically
        user = User(username=username, password=password, superuser=superuser)    # create a new user object with the provided username, password, and superuser status
        session.add(user)
        session.commit()
        session.refresh(user)
        typer.echo(f"created {username} user")
        return user


@cli.command()
def shell():  
    """Opens an interactive shell with objects auto imported"""
    _vars = {
        "app": app,
        "settings": settings,
        "User": User,
        "engine": engine,
        "cli": cli,
        "create_user": create_user,
        "select": select,
        "session": Session(engine),
        "Content": Content,
    }
    typer.echo(f"Auto imports: {list(_vars.keys())}")                          ## list of auto imported objects
    try:
        from IPython import start_ipython

        start_ipython(argv=[], user_ns=_vars)
    except ImportError:
        import code

        code.InteractiveConsole(_vars).interact()