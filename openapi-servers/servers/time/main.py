from fastapi import FastAPI
from datetime import datetime

app = FastAPI()

@app.get("/time")
async def get_time():
    return {"current_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
