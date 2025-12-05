# aiogram_scaffold

A minimal aiogram bot scaffold for quick project setup.

## Quick Start

1. **Run the setup script:**
   ```bash
   bash setup.sh
   ```
   This will:
   - Create a Python virtual environment
   - Install dependencies
   - Generate project structure
   - Create `.env` and `.env.example` files

2. **Add your bot token:**
   - Edit `.env` and set your `BOT_TOKEN`

3. **Start the bot:**
   ```bash
   source .venv/bin/activate
   python main.py
   ```

## Project Structure

- `main.py` - Bot entry point
- `config.py` - Configuration and environment variables
- `handlers/` - Message handlers and commands
- `utils/` - Utility functions
- `requirements.txt` - Dependencies

## Commands

The bot includes:
- `/start` - Start the bot
- `/help` - Show help message