// Configuração da API Azure
const CONFIG = {
    // URL da Azure Function (atualize após o deploy)
    API_URL: 'https://YOUR-FUNCTION-APP.azurewebsites.net/api',
    
    // Endpoints
    ENDPOINTS: {
        SAVE: '/formularios',      // POST
        GET_ALL: '/formularios',   // GET
        GET_ONE: '/formularios'    // GET ?protocolo=XXX
    },
    
    // Modo de operação
    MODE: 'hybrid', // 'hybrid' = salva local + sincroniza | 'online' = só servidor
    
    // Configurações de sincronização
    SYNC: {
        AUTO: true,              // Sincronizar automaticamente
        INTERVAL: 30000,         // Intervalo de sincronização (30 segundos)
        RETRY_ATTEMPTS: 3,       // Tentativas em caso de erro
        RETRY_DELAY: 5000        // Delay entre tentativas (5 segundos)
    },
    
    // Timeout para requests
    TIMEOUT: 30000 // 30 segundos
};

// Detectar se está online
function isOnline() {
    return navigator.onLine;
}

// Event listeners para status da conexão
window.addEventListener('online', () => {
    console.log('🟢 Conexão restaurada - iniciando sincronização...');
    if (CONFIG.SYNC.AUTO && typeof sincronizarComServidor === 'function') {
        sincronizarComServidor();
    }
});

window.addEventListener('offline', () => {
    console.log('🔴 Sem conexão - trabalhando offline');
});
