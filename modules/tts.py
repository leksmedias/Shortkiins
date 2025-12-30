"""Text-to-speech module using Inworld AI API."""

import logging
from pathlib import Path
from typing import Optional
import requests
from config import settings

logger = logging.getLogger(__name__)


class InworldTTS:
    """Inworld AI Text-to-Speech client."""

    def __init__(self, api_key: Optional[str] = None):
        """Initialize the Inworld TTS client.

        Args:
            api_key: Inworld API base64 credential. If not provided, uses settings.
        """
        self.api_key = api_key or settings.inworld_api_key
        self.base_url = "https://api.inworld.ai"

        if not self.api_key:
            raise ValueError("Inworld API key not configured")

    def generate_audio(
        self,
        text: str,
        output_path: Path,
        voice_id: Optional[str] = "Dennis",
        model_id: str = "inworld-tts-1",
        sample_rate: int = 22050,
        enable_timestamps: bool = True,
    ) -> Path:
        """Generate audio from text using Inworld AI TTS API.

        Args:
            text: The text to convert to speech (max 2000 characters)
            output_path: Where to save the generated audio
            voice_id: Voice ID to use (default: Dennis)
            model_id: Model ID - 'inworld-tts-1' or 'inworld-tts-1-max'
            sample_rate: Sample rate in Hz (8000-48000)
            enable_timestamps: Return word timestamp alignment

        Returns:
            Path to the generated audio file

        Raises:
            RuntimeError: If audio generation fails
        """
        import base64
        import json

        logger.info(f"Generating voiceover with Inworld AI TTS...")
        logger.info(f"Voice: {voice_id}, Model: {model_id}")

        try:
            # Inworld AI TTS API endpoint
            url = f"{self.base_url}/tts/v1/voice"

            # Basic authentication header
            headers = {
                "Authorization": f"Basic {self.api_key}",
                "Content-Type": "application/json",
            }

            # Request payload
            payload = {
                "text": text[:2000],  # Max 2000 characters
                "voiceId": voice_id,
                "modelId": model_id,
                "audioConfig": {
                    "audioEncoding": "MP3",
                    "sampleRateHertz": sample_rate,
                    "speakingRate": 1.0,
                },
                "temperature": 1.1,
            }

            # Enable word timestamps if requested
            if enable_timestamps:
                payload["timestampType"] = "WORD"

            # Make API request
            response = requests.post(url, headers=headers, json=payload, timeout=60)
            response.raise_for_status()

            result = response.json()

            # Decode base64 audio content
            audio_base64 = result["audioContent"]
            audio_data = base64.b64decode(audio_base64)

            # Save audio file
            output_path.parent.mkdir(parents=True, exist_ok=True)
            output_path.write_bytes(audio_data)

            # Save word timestamps if available
            if "timestampInfo" in result and "wordAlignment" in result["timestampInfo"]:
                alignment = result["timestampInfo"]["wordAlignment"]
                timestamps_path = output_path.with_suffix(".timestamps.json")

                timestamp_data = {
                    "words": alignment.get("words", []),
                    "wordStartTimeSeconds": alignment.get("wordStartTimeSeconds", []),
                    "wordEndTimeSeconds": alignment.get("wordEndTimeSeconds", []),
                }

                with open(timestamps_path, "w") as f:
                    json.dump(timestamp_data, f, indent=2)

                logger.info(f"Word timestamps saved to: {timestamps_path}")

            logger.info(f"Audio saved to: {output_path}")
            return output_path

        except requests.exceptions.HTTPError as e:
            logger.error(f"HTTP error from Inworld API: {e}")
            logger.error(f"Response: {e.response.text if e.response else 'No response'}")
            raise RuntimeError(f"Inworld TTS API error: {e}")
        except Exception as e:
            logger.error(f"Failed to generate audio: {e}")
            raise RuntimeError(f"TTS generation failed: {e}")


def generate_voiceover(
    script: str,
    output_path: Path,
    voice_id: Optional[str] = None,
) -> Path:
    """Generate voiceover from script using Inworld AI.

    Args:
        script: The script text
        output_path: Where to save the audio file
        voice_id: Optional custom voice ID

    Returns:
        Path to the generated audio file
    """
    tts = InworldTTS()
    return tts.generate_audio(script, output_path, voice_id)


# Alternative: AsyncFlow TTS with word timestamps
class AsyncFlowTTS:
    """AsyncFlow Text-to-Speech with word timestamps."""

    def __init__(self, api_key: Optional[str] = None):
        """Initialize AsyncFlow TTS client.

        Args:
            api_key: AsyncFlow API key. If not provided, uses settings.
        """
        self.api_key = api_key or settings.asyncflow_api_key
        self.base_url = "https://api.async.ai"  # Replace with actual base URL

        if not self.api_key:
            raise ValueError("AsyncFlow API key not configured")

    def generate_audio(
        self,
        text: str,
        output_path: Path,
        voice_id: str = "e0f39dc4-f691-4e78-bba5-5c636692cc04",
        model_id: str = "asyncflow_v2.0",
        language: Optional[str] = "en",
    ) -> Path:
        """Generate audio with word timestamps using AsyncFlow.

        Args:
            text: The text to convert to speech
            output_path: Where to save the generated audio
            voice_id: Voice ID to use
            model_id: Model to use (asyncflow_v2.0 or asyncflow_multilingual_v1.0)
            language: Language code (ISO 639-1)

        Returns:
            Path to the generated audio file

        Raises:
            RuntimeError: If audio generation fails
        """
        import base64
        import json

        logger.info(f"Generating voiceover with AsyncFlow TTS...")

        try:
            url = f"{self.base_url}/text_to_speech/with_timestamps"
            headers = {
                "x-api-key": self.api_key,
                "version": "v1",
                "Content-Type": "application/json",
            }

            payload = {
                "model_id": model_id,
                "transcript": text,
                "voice": {"mode": "id", "id": voice_id},
                "output_format": {
                    "container": "mp3",
                    "sample_rate": 44100,
                    "bit_rate": 192000,
                },
            }

            if language:
                payload["language"] = language

            response = requests.post(url, headers=headers, json=payload, timeout=60)
            response.raise_for_status()

            result = response.json()

            # Decode base64 audio
            audio_base64 = result["audio_base64"]
            audio_data = base64.b64decode(audio_base64)

            # Save audio file
            output_path.parent.mkdir(parents=True, exist_ok=True)
            output_path.write_bytes(audio_data)

            # Save word timestamps for reference
            alignment = result.get("alignment")
            if alignment:
                timestamps_path = output_path.with_suffix(".timestamps.json")
                with open(timestamps_path, "w") as f:
                    json.dump(alignment, f, indent=2)
                logger.info(f"Word timestamps saved to: {timestamps_path}")

            logger.info(f"Audio saved to: {output_path}")
            return output_path

        except Exception as e:
            logger.error(f"Failed to generate audio: {e}")
            raise RuntimeError(f"AsyncFlow TTS generation failed: {e}")


def generate_voiceover_asyncflow(
    script: str,
    output_path: Path,
    voice_id: Optional[str] = None,
) -> Path:
    """Generate voiceover using AsyncFlow TTS with word timestamps.

    Args:
        script: The script text
        output_path: Where to save the audio file
        voice_id: Optional custom voice ID

    Returns:
        Path to the generated audio file
    """
    tts = AsyncFlowTTS()
    default_voice = "e0f39dc4-f691-4e78-bba5-5c636692cc04"
    return tts.generate_audio(script, output_path, voice_id or default_voice)
