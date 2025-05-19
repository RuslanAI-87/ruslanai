$content = Get-Content -Path C:\RuslanAI\web_ui\src\components\RuslanAI.jsx -Raw
$pattern = "const {
    isRecording: isAudioRecording,
    transcribedText,
    error: recordingError,
    toggleRecording: toggleAudioRecording
  } = useAudioRecorder();"

$replacement = "const {
    isRecording: isAudioRecording,
    transcribedText,
    error: recordingError,
    status: recordingStatus,
    toggleRecording: toggleAudioRecording
  } = useAudioRecorder();"

$content = $content.Replace($pattern, $replacement)
Set-Content -Path C:\RuslanAI\web_ui\src\components\RuslanAI.jsx -Value $content -Encoding UTF8