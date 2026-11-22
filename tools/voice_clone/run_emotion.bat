@echo off
rem The EMOTION run (docs/chatterbox_todo.md): the emotional campaign lines again, into out_emotion\.
cd /d "%~dp0"
call venv\Scripts\activate
python clone_lines.py --lines lines_emotion.txt --out out_emotion
pause
