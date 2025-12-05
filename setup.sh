#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check Python version
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Python 3 is not installed${NC}"
    exit 1
fi

python_version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
echo -e "${BLUE}Found Python ${python_version}${NC}"

# Detect OS and set activation command
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    VENV_ACTIVATE=".venv/Scripts/activate"
else
    VENV_ACTIVATE=".venv/bin/activate"
fi

# Create virtual environment if it doesn't exist
if [ -d ".venv" ]; then
    echo -e "${GREEN}✓ Virtual environment already exists${NC}"
else
    echo -e "${BLUE}Creating virtual environment...${NC}"
    python3 -m venv .venv || { echo -e "${RED}✗ Failed to create venv${NC}"; exit 1; }
    echo -e "${GREEN}✓ Virtual environment created${NC}"
fi

# Activate virtual environment
source "$VENV_ACTIVATE"

# Create project structure
mkdir -p handlers utils

# Create Python package files
touch handlers/__init__.py utils/__init__.py

# Create main files
cat > config.py << 'EOF'
import os
from dotenv import load_dotenv

load_dotenv()

BOT_TOKEN = os.getenv("BOT_TOKEN")

if not BOT_TOKEN:
    raise ValueError("BOT_TOKEN is not set in .env file")
EOF

cat > main.py << 'EOF'
import asyncio
import logging
from aiogram import Bot, Dispatcher
from aiogram.client.default import DefaultBotProperties
from aiogram.enums import ParseMode

from config import BOT_TOKEN
from handlers import router

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


async def main():
    bot = Bot(
        token=BOT_TOKEN,
        default=DefaultBotProperties(parse_mode=ParseMode.HTML)
    )
    dp = Dispatcher()
    dp.include_router(router)

    try:
        logger.info("Starting bot...")
        await dp.start_polling(bot)
    finally:
        await bot.session.close()


if __name__ == "__main__":
    asyncio.run(main())
EOF

cat > handlers/__init__.py << 'EOF'
from aiogram import Router
from .start import router as start_router

router = Router()
router.include_router(start_router)
EOF

cat > handlers/start.py << 'EOF'
from aiogram import Router
from aiogram.filters import Command
from aiogram.types import Message

router = Router()


@router.message(Command("start"))
async def cmd_start(message: Message):
    await message.answer("Hello! Bot is running.")


@router.message(Command("help"))
async def cmd_help(message: Message):
    await message.answer("Available commands:\n/start - Start the bot\n/help - Show this help message")
EOF

touch utils/__init__.py

# Create requirements.txt
cat > requirements.txt << 'EOF'
aiogram
python-dotenv
EOF


# Create .env
cat > .env << 'EOF'
BOT_TOKEN=
EOF

# Install requirements
echo -e "${BLUE}Installing dependencies...${NC}"
pip install -q -r requirements.txt || { echo -e "${RED}✗ Failed to install dependencies${NC}"; exit 1; }
echo -e "${GREEN}✓ Dependencies installed${NC}"

echo ""
echo -e "${GREEN}✓ Project structure created!${NC}"
echo -e "${GREEN}✓ Virtual environment created and activated${NC}"
echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Edit .env and set your BOT_TOKEN"
echo "2. Run the bot: python main.py"
echo ""
echo -e "${BLUE}To deactivate virtual environment later:${NC}"
echo "   deactivate"
