// Configuração da API Netlify Functions para GERENTES
const CONFIG = {
    // URL das Netlify Functions
    API_URL: '/.netlify/functions',
    
    // Endpoints ESPECÍFICOS para GERENTES
    ENDPOINTS: {
        SAVE: '/salvar-gerentes',       // POST → salva em formulario_gerentes
        GET_ALL: '/buscar-gerentes',    // GET → busca de formulario_gerentes
        GET_ONE: '/buscar-gerentes'     // GET ?protocolo=XXX
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
    console.log('🟢 [GERENTES] Conexão restaurada - iniciando sincronização...');
    if (CONFIG.SYNC.AUTO && typeof sincronizarComServidor === 'function') {
        sincronizarComServidor();
    }
});

window.addEventListener('offline', () => {
    console.log('🔴 [GERENTES] Sem conexão - trabalhando offline');
});

console.log('✅ CONFIG para GERENTES carregado:', CONFIG.ENDPOINTS);
