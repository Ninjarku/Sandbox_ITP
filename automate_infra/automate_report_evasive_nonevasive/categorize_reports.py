import pdfplumber
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import time
import os

class ReportHandler(FileSystemEventHandler):
    def __init__(self, keywords):
        self.keywords = keywords

    def on_created(self, event):
        # Check if the new file is a PDF
        if event.is_directory or not event.src_path.endswith(".pdf"):
            return
        file_path = event.src_path
        category = self.categorize_report(file_path)
        print(f"The report '{os.path.basename(file_path)}' is categorized as: {category}")

    def categorize_report(self, file_path):
        category = "Non-evasive"
        try:
            with pdfplumber.open(file_path) as pdf:
                for page in pdf.pages:
                    text = page.extract_text()
                    if text:
                        for keyword in self.keywords:
                            if keyword in text:
                                category = "Evasive"
                                break
                    if category == "Evasive":
                        break
        except Exception as e:
            print(f"An error occurred while processing {file_path}: {e}")
        return category

# Define evasive keywords based on common evasion indicators
evasive_keywords = [
    "SandboxHookingDLL", "Sandbox_Evasion", "VM_Evasion", "vmdetect",
    "INDICATOR_SUSPICIOUS_Sandbox_Evasion", "INDICATOR_SUSPICIOUS_VM_Evasion_MACAddrComb"
]

# Set up the observer to monitor the CAPE reports directory
path_to_watch = "/opt/CAPEv2/storage/analyses/latest/reports"
if not os.path.exists(path_to_watch):
    print(f"Error: Path '{path_to_watch}' does not exist. Check the directory location.")
    exit(1)

event_handler = ReportHandler(evasive_keywords)
observer = Observer()
observer.schedule(event_handler, path=path_to_watch, recursive=False)

try:
    observer.start()
    print(f"Monitoring folder: {path_to_watch}")
    while True:
        time.sleep(1)  # Keep the script running
except KeyboardInterrupt:
    observer.stop()
    print("Monitoring stopped by user.")
observer.join()
