$content = Get-Content -Path C:\RuslanAI\web_ui\src\components\RuslanAI.jsx -Raw
$pattern = '<div className="relative">'
$replacement = '<div className="relative">
                    {/* Индикатор записи */}
                    {recordingStatus && recordingStatus !== "idle" && (
                      <div className="absolute -top-8 left-0 z-10">
                        <RecordingIndicator 
                          status={recordingStatus} 
                          error={recordingError} 
                        />
                      </div>
                    )}'

$content = $content.Replace($pattern, $replacement)
Set-Content -Path C:\RuslanAI\web_ui\src\components\RuslanAI.jsx -Value $content -Encoding UTF8