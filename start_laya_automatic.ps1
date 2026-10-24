# start_laya_automatic.ps1
# Script PowerShell para registrar a Laya Service como inicialização automática no Windows

# Caminho absoluto para o serviço Laya
$layaServicePath = "C:\Users\raul.guimaraes\projects\asimov-stack-config\start_laya.cmd"

# Nome da Tarefa Agendada
$taskName = "LayaDecisionService"

# Verificar se a tarefa já existe
$task = schtasks /query /tn $taskName 2>$null

if ($task) {
    Write-Host "[Laya] Tarefa agendada já existe. Atualizando..."
    schtasks /change /tn $taskName /ru "SYSTEM" /rl HIGHEST
} else {
    Write-Host "[Laya] Criando tarefa agendada para inicialização automática (nível usuário)..."

    # Criar tarefa agendada para rodar no logon do usuário atual
    schtasks /create /tn $taskName /sc onlogon /tr `"$layaServicePath`" /f
}

Write-Host ""
Write-Host "[Laya] ✅ Configuração concluída."
Write-Host "[Laya] O serviço Laya iniciará automaticamente ao cada login do Windows."
Write-Host "[Laya] Logs disponíveis em: C:\Users\raul.guimaraes\projects\asimov-stack-config\laya.log"