# Исправление ошибок в RuslanAI.jsx
$content = Get-Content C:\RuslanAI\web_ui\src\components\RuslanAI.jsx -Raw

# Исправляем функцию formatCost
$content = $content -replace 'return \$;', 'return `$${cost.toFixed(2)}`;'

# Исправляем className атрибуты 
$content = $content -replace '\{flex flex-col h-screen \}', '"flex flex-col h-screen"'
$content = $content -replace '\{flex justify-between items-center p-4 border-b \}', '"flex justify-between items-center p-4 border-b"'
$content = $content -replace '\{flex items-center px-3 py-2 rounded-md \}', '"flex items-center px-3 py-2 rounded-md"'
$content = $content -replace '\{bsolute left-0 mt-2 w-48 rounded-md shadow-lg z-10  py-1\}', '"absolute left-0 mt-2 w-48 rounded-md shadow-lg z-10 py-1"'
$content = $content -replace '\{block px-4 py-2 text-sm \}', '"block px-4 py-2 text-sm"'
$content = $content -replace '\{w-16 flex flex-col items-center py-4 border-r \}', '"w-16 flex flex-col items-center py-4 border-r"'
$content = $content -replace '\{p-3 rounded-md mb-4 \}', '"p-3 rounded-md mb-4"'
$content = $content -replace '\{p-3 rounded-md \}', '"p-3 rounded-md"'
$content = $content -replace '\{flex \}', '"flex"'
$content = $content -replace '\{max-w-4xl rounded-lg py-2 px-4 \}', '"max-w-4xl rounded-lg py-2 px-4"'
$content = $content -replace '\{w-full p-3 rounded-lg pr-12  border focus:outline-none\}', '"w-full p-3 rounded-lg pr-12 border focus:outline-none"'
$content = $content -replace '\{bsolute right-2 top-1/2 -translate-y-1/2 p-2 rounded-full \}', '"absolute right-2 top-1/2 -translate-y-1/2 p-2 rounded-full"'
$content = $content -replace '\{p-3 rounded-lg cursor-pointer  border\}', '"p-3 rounded-lg cursor-pointer border"'
$content = $content -replace '\{grid gap-4 md:grid-cols-2 lg:grid-cols-3\}', '"grid gap-4 md:grid-cols-2 lg:grid-cols-3"'
$content = $content -replace '\{p-4 rounded-lg shadow border \}', '"p-4 rounded-lg shadow border"'
$content = $content -replace '\{mt-4 text-sm \}', '"mt-4 text-sm"'
$content = $content -replace '\{overflow-x-auto rounded-lg border \}', '"overflow-x-auto rounded-lg border"'
$content = $content -replace '\{min-w-full table-auto \}', '"min-w-full table-auto"'
$content = $content -replace '\{px-4 py-2 rounded-lg cursor-pointer  text-white flex items-center\}', '"px-4 py-2 rounded-lg cursor-pointer bg-blue-500 text-white flex items-center"'
$content = $content -replace '\{p-1 rounded-md \}', '"p-1 rounded-md"'
$content = $content -replace '\{p-1 rounded-md  ml-2\}', '"p-1 rounded-md ml-2"'
$content = $content -replace '\{p-4 rounded-lg border \}', '"p-4 rounded-lg border"'
$content = $content -replace '\{px-4 py-2 rounded-md \}', '"px-4 py-2 rounded-md"'
$content = $content -replace '\{block text-sm  mb-1\}', '"block text-sm mb-1"'
$content = $content -replace '\{w-full p-2 rounded border  focus:outline-none\}', '"w-full p-2 rounded border focus:outline-none"'

# Исправляем templateStrings с использованием $
$content = $content -replace '\$\{darkMode \? "bg-gray-800" : "bg-gray-100"\}', '"${darkMode ? "bg-gray-800" : "bg-gray-100"}"'
$content = $content -replace '\$\{darkMode \? "hover:bg-gray-700" : "hover:bg-gray-50"\}', '"${darkMode ? "hover:bg-gray-700" : "hover:bg-gray-50"}"'

# Сохраняем исправленный файл
Set-Content -Path "C:\RuslanAI\web_ui\src\components\RuslanAI.jsx" -Value $content -Encoding UTF8

Write-Host "Файл RuslanAI.jsx успешно исправлен" -ForegroundColor Green