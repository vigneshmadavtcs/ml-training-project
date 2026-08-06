import logging
import json
from pathlib import Path

import joblib
import pandas as pd
import yaml
from sklearn.datasets import load_iris
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split


# -----------------------------------------------------------------------------
# Logging Configuration
# -----------------------------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler("train.log"),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)


# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
def load_config(path: str) -> dict:
    """
    Load configuration from YAML.
    """
    try:
        with open(path, "r") as f:
            config = yaml.safe_load(f)

        logger.info("Configuration loaded successfully.")
        logger.info(f"Config: {config}")

        return config

    except FileNotFoundError:
        logger.error(f"Configuration file not found: {path}")
        raise

    except yaml.YAMLError as e:
        logger.error(f"Invalid YAML: {e}")
        raise

    except Exception as e:
        logger.exception(f"Unexpected error while reading config: {e}")
        raise


def validate_config(config: dict):
    """
    Validate required configuration values.
    """
    required_keys = {
        "learning_rate",
        "n_estimators",
        "dataset_path"
    }

    missing = required_keys - config.keys()

    if missing:
        raise ValueError(
            f"Missing configuration keys: {missing}"
        )

    if config["learning_rate"] <= 0:
        raise ValueError("learning_rate must be greater than 0")

    if config["n_estimators"] <= 0:
        raise ValueError("n_estimators must be greater than 0")

    logger.info("Configuration validation successful.")


# -----------------------------------------------------------------------------
# Dataset
# -----------------------------------------------------------------------------
def load_dataset(dataset_path: str):
    """
    Load Iris dataset or CSV dataset.
    """

    try:

        if dataset_path.lower() == "iris":

            logger.info("Loading Iris dataset...")

            iris = load_iris()

            X = iris.data
            y = iris.target

        else:

            dataset = Path(dataset_path)

            if not dataset.exists():
                raise FileNotFoundError(
                    f"Dataset not found: {dataset_path}"
                )

            logger.info(f"Loading dataset from {dataset_path}")

            df = pd.read_csv(dataset)

            X = df.drop(columns=["target"])
            y = df["target"]

        logger.info("Dataset loaded successfully.")

        return X, y

    except FileNotFoundError as e:
        logger.error(e)
        raise

    except KeyError:
        logger.error(
            "Dataset must contain a column named 'target'."
        )
        raise

    except pd.errors.ParserError as e:
        logger.error(f"CSV parsing failed: {e}")
        raise

    except Exception as e:
        logger.exception(f"Dataset loading failed: {e}")
        raise


# -----------------------------------------------------------------------------
# Training
# -----------------------------------------------------------------------------
def train_model(config: dict):

    try:

        logger.info("Training started.")

        X, y = load_dataset(config["dataset_path"])

        X_train, X_test, y_train, y_test = train_test_split(
            X,
            y,
            test_size=0.2,
            random_state=42,
            stratify=y
        )

        model = GradientBoostingClassifier(
            learning_rate=config["learning_rate"],
            n_estimators=config["n_estimators"],
            random_state=42
        )

        logger.info(
            "Hyperparameters: "
            f"learning_rate={config['learning_rate']}, "
            f"n_estimators={config['n_estimators']}"
        )

        model.fit(X_train, y_train)

        predictions = model.predict(X_test)

        accuracy = accuracy_score(
            y_test,
            predictions
        )

        logger.info("Training completed successfully.")
        logger.info(f"Final Accuracy: {accuracy:.4f}")

        return model, accuracy

    except Exception as e:
        logger.exception(f"Training failed: {e}")
        raise


# -----------------------------------------------------------------------------
# Save Model
# -----------------------------------------------------------------------------
def save_model(model, filename="model.joblib"):

    try:

        joblib.dump(model, filename)

        logger.info(f"Model saved to {filename}")

    except Exception as e:
        logger.exception(f"Failed to save model: {e}")
        raise


# -----------------------------------------------------------------------------
# Save Metrics
# -----------------------------------------------------------------------------
def save_metrics(accuracy, filename="metrics.json"):

    try:

        metrics = {
            "accuracy": round(accuracy, 4)
        }

        with open(filename, "w") as f:
            json.dump(
                metrics,
                f,
                indent=4
            )

        logger.info(f"Metrics saved to {filename}")

    except Exception as e:
        logger.exception(f"Failed to save metrics: {e}")
        raise


# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
def main():

    try:

        config = load_config("config.yaml")

        validate_config(config)

        model, accuracy = train_model(config)

        save_model(model)

        save_metrics(accuracy)

        logger.info("Training pipeline completed successfully.")
        logger.info("Training completed with metrics saved with effort.")

    except Exception:
        logger.exception("Pipeline execution failed.")


if __name__ == "__main__":
    main()