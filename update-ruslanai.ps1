# Обновление RuslanAI.jsx для добавления индикатора состояния
$content = Get-Content C:\RuslanAI\web_ui\src\components\RuslanAI.jsx -Raw

# Добавление импорта RecordingIndicator
$importPattern = 'import React, \{ useState, useEffect \} from "react";'
$newImport = 'import React, { useState, useEffect } from "react";
import RecordingIndicator from "./RecordingIndicator";'
$content = $content -replace $importPattern, $newImport

# Обновление деструктуризации хука useAudioRecorder
$hookPattern = 'const \{
    isRecording: isAudioRecording,
    transcribedText,
    error: recordingError,
    toggleRecording: toggleAudioRecording
  \} = useAudioRecorder\(\);'
$newHook = 'const {
    isRecording: isAudioRecording,
    transcribedText,
    error: recordingError,
    status: recordingStatus,
    logs: recordingLogs,
    toggleRecording: toggleAudioRecording
  } = useAudioRecorder();'
$content = $content -replace $hookPattern, $newHook

# Добавление индикатора состояния в UI чата
$inputPattern = '<div className="relative flex-1">'
$newInput = '<div className="relative flex-1">
                    {/* Индикатор статуса записи */}
                    {recordingStatus !== "idle" && (
                      <div className="absolute -top-8 left-0 z-10">
                        <RecordingIndicator 
                          status={recordingStatus} 
                          error={recordingError} 
                        />
                      </div>
                    )}'
$content = $content -replace $inputPattern, $newInput

# Сохраняем обновленный файл
Set-Content -Path "C:\RuslanAI\web_ui\src\components\RuslanAI.jsx" -Value $content -Encoding UTF8

Write-Host "Файл RuslanAI.jsx успешно обновлен с индикатором состояния" -ForegroundColor Green