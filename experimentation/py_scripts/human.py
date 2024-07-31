import math
import os
import time
import random
import zipfile
import subprocess
import pyautogui
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from threading import Thread
import signal
import sys
import logging

# Constants
DESKTOP_PATH = os.path.join(os.path.join(os.environ['USERPROFILE']), 'Desktop')
DOWNLOADS_PATH = os.path.join(os.path.join(os.environ['USERPROFILE']), 'Downloads')

CHECK_INTERVAL = 1  # seconds
ENTER_INTERVAL_MIN = 10  # seconds
ENTER_INTERVAL_MAX = 40  # seconds
SCROLL_INTERVAL = 5  # seconds
LEFT = 50 # Pixels from the side fo screen (Adjust accordingly)

# Var
observer = None

# Log File
LOG_FILE = os.path.join(DESKTOP_PATH, 'user_actions.log')

# Human-like movement parameters
DURATION = 1  # duration of mouse movement
TWEEN = pyautogui.easeInOutQuad

# List of known executables
# known_executables = set()

logging.basicConfig(filename=LOG_FILE, level=logging.INFO, format='%(asctime)s - %(message)s')

def minimize_all_windows():
    """
    Function to minimize all open windows to show the desktop.
    """
    pyautogui.hotkey('win', 'd')
    logging.info(f"All windows minimized to show desktop")
    return


def random_user_actions():
    """
    Function that will simulate the random human action such as hitting enter button scrolling,
    clicking on middle of screen
    """
    screen_width, screen_height = pyautogui.size()
    center_x, center_y = screen_width // 2, screen_height // 2
    radius = 100  # Radius for random deviation

    while True:
        # Make the cursor deviate as humans cannot always stop the mouse that the true center of the screen
        angle = random.uniform(0, 2 * math.pi)
        deviation_x = int(center_x + radius * math.cos(angle))
        deviation_y = int(center_y + radius * math.sin(angle))

        #  clicking the centerish of the screen
        pyautogui.moveTo(deviation_x, deviation_y, duration=1, tween=TWEEN)
        pyautogui.click()

        # Randomly press 'enter' after clicking the screen
        time.sleep(random.randint(ENTER_INTERVAL_MIN, ENTER_INTERVAL_MAX))
        pyautogui.press('enter')

        # Wait a random amount of time (5-40 seconds) before the next action
        time.sleep(random.randint(SCROLL_INTERVAL, ENTER_INTERVAL_MAX))
        # Scroll down
        pyautogui.scroll(-100)


def random_mouse_movement(duration=5):
    """
    Simulates random mouse movements across the screen for a specified duration.

    Args:
        duration (int): The duration in seconds for which the mouse movements will be simulated.
    """
    start_time = time.time()
    screen_width, screen_height = pyautogui.size()

    while time.time() - start_time < duration:
        x = random.randint(0, screen_width - 1)
        y = random.randint(0, screen_height - 1)
        pyautogui.moveTo(x, y, duration=random.uniform(0.1, 1))
        time.sleep(random.uniform(0.1, 0.5))


def random_mouse_clicks(duration=10, click_count=20):
    """
    Simulates random mouse clicks at random positions on the screen for a specified duration or click count.

    Args:
        duration (int): The duration in seconds for which the mouse clicks will be simulated.
        click_count (int): The number of clicks to simulate.
    """
    start_time = time.time()
    screen_width, screen_height = pyautogui.size()

    for _ in range(click_count):
        if time.time() - start_time >= duration:
            break
        x = random.randint(0, screen_width - 1)
        y = random.randint(0, screen_height - 1)
        pyautogui.click(x, y)
        time.sleep(random.uniform(0.1, 1))


def random_keyboard_typing(duration=10):
    """
    Simulates random keyboard typing for a specified duration.

    Args:
        duration (int): The duration in seconds for which the keyboard typing will be simulated.
    """
    start_time = time.time()
    characters = string.ascii_letters + string.digits + string.punctuation

    while time.time() - start_time < duration:
        random_text = ''.join(random.choices(characters, k=random.randint(1, 10)))
        pyautogui.write(random_text, interval=random.uniform(0.1, 0.5))
        pyautogui.press('enter')
        time.sleep(random.uniform(0.5, 2))

def monitor_desktop():
    """
    Function will invoke the file handler and observeer to monitor the desktop activities that will trigger
    the required responses accordingly
    """
    logging.info(f"Human begun moving...")
    
    event_handler = NewFileHandler()
    observer = Observer()
    observer.schedule(event_handler, path=DESKTOP_PATH, recursive=False)
    observer.start()

    # Unzip the file
    unzip_file(DOWNLOADS_PATH, DESKTOP_PATH, ZIP_FILE_NAME)
    try:
        while True:
            time.sleep(CHECK_INTERVAL)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()


def signal_handler(sig, frame):
    """
    Function ensure the exit does not cause memory leak and exits the program safely
    Args:
        sig:
        frame:
    """
    logging.info(f"Termination signal received. Shutting down...")
    if observer is not None:
        observer.stop()
        observer.join()
    logging.info(f"Exiting safely...")
    sys.exit(0)


if __name__ == "__main__":
    # Define signal handlers
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    # Minimize all windows at the start
    minimize_all_windows()

    random_action_thread = Thread(target=random_user_actions)
    random_action_thread.daemon = True
    random_action_thread.start()

    monitor_desktop()
