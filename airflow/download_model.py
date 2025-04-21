from transformers import AutoModelForSequenceClassification, AutoTokenizer
import os

MODEL_NAME = "typeform/distilbert-base-uncased-mnli"
MODEL_DIR = "./models/typeform-mnli"

def download_model():
    if not os.path.exists(MODEL_DIR):
        print("Downloading model...")
        model = AutoModelForSequenceClassification.from_pretrained(MODEL_NAME)
        tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)

        os.makedirs(MODEL_DIR, exist_ok=True)
        model.save_pretrained(MODEL_DIR)
        tokenizer.save_pretrained(MODEL_DIR)
        print(f"Model saved to {MODEL_DIR}")
    else:
        print("Model already exists locally.")

if __name__ == "__main__":
    download_model()
