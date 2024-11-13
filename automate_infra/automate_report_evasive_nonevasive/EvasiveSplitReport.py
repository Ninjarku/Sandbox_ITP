import pdfplumber

def categorize_report(file_path):
    # Define keywords that indicate evasive behavior
    evasive_keywords = [
        "SandboxHookingDLL", "Sandbox_Evasion", "VM_Evasion", "vmdetect",
        "INDICATOR_SUSPICIOUS_Sandbox_Evasion", "INDICATOR_SUSPICIOUS_VM_Evasion_MACAddrComb"
    ]
    
    # Default category is "Non-evasive"
    category = "Non-evasive"
    
    try:
        with pdfplumber.open(file_path) as pdf:
            # Iterate over each page in the PDF
            for page in pdf.pages:
                text = page.extract_text()
                # Check if any evasive keyword is present in the text
                if text:
                    for keyword in evasive_keywords:
                        if keyword in text:
                            category = "Evasive"
                            break
                if category == "Evasive":
                    break
    except Exception as e:
        print(f"An error occurred while processing the file: {e}")
    
    return category


file_path = "/opt/CAPEv2/storage/report.pdf"
category = categorize_report(file_path)
print(f"The report is categorized as: {category}")
