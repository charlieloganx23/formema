// ==================================================
// INDEXEDDB - Formulário de Extensionistas EMATER-RO
// ==================================================
// Versão: 1.0
// Data: 08/12/2025
// Propósito: Armazenamento local offline de respostas

const DB_NAME = 'EmatechExtensionistas';
const DB_VERSION = 1;
const STORE_NAME = 'formularios';

let db = null;

// ==================================================
// INICIALIZAÇÃO DO BANCO
// ==================================================

async function initDB() {
    return new Promise((resolve, reject) => {
        const request = indexedDB.open(DB_NAME, DB_VERSION);

        request.onerror = () => {
            console.error('Erro ao abrir IndexedDB:', request.error);
            reject(request.error);
        };

        request.onsuccess = () => {
            db = request.result;
            console.log('✅ IndexedDB inicializado com sucesso');
            resolve(db);
        };

        request.onupgradeneeded = (event) => {
            db = event.target.result;
            
            // Criar object store se não existir
            if (!db.objectStoreNames.contains(STORE_NAME)) {
                const objectStore = db.createObjectStore(STORE_NAME, { 
                    keyPath: 'id', 
                    autoIncrement: true 
                });
                
                // Criar índices
                objectStore.createIndex('protocolo', 'protocolo', { unique: true });
                objectStore.createIndex('municipio', 'municipio', { unique: false });
                objectStore.createIndex('timestamp_fim', 'timestamp_fim', { unique: false });
                objectStore.createIndex('sincronizado', 'sincronizado', { unique: false });
                
                console.log('✅ Object store criado com índices');
            }
        };
    });
}

// ==================================================
// SALVAR FORMULÁRIO
// ==================================================

async function salvarFormulario(dados) {
    if (!db) {
        await initDB();
    }

    return new Promise(async (resolve, reject) => {
        const transaction = db.transaction([STORE_NAME], 'readwrite');
        const objectStore = transaction.objectStore(STORE_NAME);

        // Gerar protocolo único
        const protocolo = gerarProtocolo();
        
        // Adicionar metadados
        const formulario = {
            ...dados,
            protocolo: protocolo,
            timestamp_fim: new Date().toISOString(),
            sincronizado: false,
            versao_formulario: '1.0'
        };

        const request = objectStore.add(formulario);

        request.onsuccess = async () => {
            console.log('✅ Formulário salvo no IndexedDB:', protocolo);
            
            // Tentar sincronizar imediatamente com o servidor
            try {
                if (navigator.onLine) {
                    console.log('🌐 [SAVE] Online detectado, iniciando sincronização automática...');
                    const resultadoSync = await sincronizarFormularioComAzure(formulario);
                    
                    console.log('📊 [SAVE] Resultado da sincronização:', resultadoSync);
                    
                    if (resultadoSync.success) {
                        console.log('✅ [SAVE] Formulário sincronizado automaticamente!');
                        resolve({ 
                            success: true, 
                            protocolo: protocolo, 
                            id: request.result,
                            sincronizado: true 
                        });
                    } else {
                        console.warn('⚠️ [SAVE] Sincronização falhou:', resultadoSync.error);
                        console.log('💾 [SAVE] Salvo localmente, sincronização pendente');
                        resolve({ 
                            success: true, 
                            protocolo: protocolo, 
                            id: request.result,
                            sincronizado: false 
                        });
                    }
                } else {
                    console.log('📴 [SAVE] Offline - formulário será sincronizado quando houver conexão');
                    resolve({ 
                        success: true, 
                        protocolo: protocolo, 
                        id: request.result,
                        sincronizado: false 
                    });
                }
            } catch (error) {
                console.error('❌ [SAVE] Erro na sincronização automática:', error);
                console.error('❌ [SAVE] Stack:', error.stack);
                // Mesmo com erro na sync, o salvamento local foi bem-sucedido
                resolve({ 
                    success: true, 
                    protocolo: protocolo, 
                    id: request.result,
                    sincronizado: false 
                });
            }
        };

        request.onerror = () => {
            console.error('❌ Erro ao salvar formulário:', request.error);
            reject(request.error);
        };
    });
}

// ==================================================
// BUSCAR TODOS OS FORMULÁRIOS
// ==================================================

async function buscarTodosFormularios() {
    if (!db) {
        await initDB();
    }

    return new Promise((resolve, reject) => {
        const transaction = db.transaction([STORE_NAME], 'readonly');
        const objectStore = transaction.objectStore(STORE_NAME);
        const request = objectStore.getAll();

        request.onsuccess = () => {
            resolve(request.result);
        };

        request.onerror = () => {
            reject(request.error);
        };
    });
}

// ==================================================
// BUSCAR FORMULÁRIO POR PROTOCOLO
// ==================================================

async function buscarPorProtocolo(protocolo) {
    if (!db) {
        await initDB();
    }

    return new Promise((resolve, reject) => {
        const transaction = db.transaction([STORE_NAME], 'readonly');
        const objectStore = transaction.objectStore(STORE_NAME);
        const index = objectStore.index('protocolo');
        const request = index.get(protocolo);

        request.onsuccess = () => {
            resolve(request.result);
        };

        request.onerror = () => {
            reject(request.error);
        };
    });
}

// ==================================================
// BUSCAR FORMULÁRIOS NÃO SINCRONIZADOS
// ==================================================

async function buscarNaoSincronizados() {
    if (!db) {
        await initDB();
    }

    return new Promise((resolve, reject) => {
        const transaction = db.transaction([STORE_NAME], 'readonly');
        const objectStore = transaction.objectStore(STORE_NAME);
        const request = objectStore.getAll();

        request.onsuccess = () => {
            // Filtrar manualmente os não sincronizados
            const naoSincronizados = request.result.filter(form => !form.sincronizado);
            resolve(naoSincronizados);
        };

        request.onerror = () => {
            reject(request.error);
        };
    });
}

// ==================================================
// MARCAR COMO SINCRONIZADO
// ==================================================

async function marcarComoSincronizado(id) {
    if (!db) {
        await initDB();
    }

    return new Promise((resolve, reject) => {
        const transaction = db.transaction([STORE_NAME], 'readwrite');
        const objectStore = transaction.objectStore(STORE_NAME);
        const request = objectStore.get(id);

        request.onsuccess = () => {
            const formulario = request.result;
            if (formulario) {
                formulario.sincronizado = true;
                formulario.timestamp_sinc = new Date().toISOString();
                
                const updateRequest = objectStore.put(formulario);
                
                updateRequest.onsuccess = () => {
                    resolve({ success: true });
                };
                
                updateRequest.onerror = () => {
                    reject(updateRequest.error);
                };
            } else {
                reject(new Error('Formulário não encontrado'));
            }
        };

        request.onerror = () => {
            reject(request.error);
        };
    });
}

// ==================================================
// CONTAR FORMULÁRIOS
// ==================================================

async function contarFormularios() {
    if (!db) {
        await initDB();
    }

    return new Promise((resolve, reject) => {
        const transaction = db.transaction([STORE_NAME], 'readonly');
        const objectStore = transaction.objectStore(STORE_NAME);
        const request = objectStore.count();

        request.onsuccess = () => {
            resolve(request.result);
        };

        request.onerror = () => {
            reject(request.error);
        };
    });
}

// ==================================================
// LIMPAR TODOS OS DADOS (cuidado!)
// ==================================================

async function limparTodosDados() {
    if (!db) {
        await initDB();
    }

    return new Promise((resolve, reject) => {
        const transaction = db.transaction([STORE_NAME], 'readwrite');
        const objectStore = transaction.objectStore(STORE_NAME);
        const request = objectStore.clear();

        request.onsuccess = () => {
            console.log('⚠️ Todos os dados foram removidos do IndexedDB');
            resolve({ success: true });
        };

        request.onerror = () => {
            reject(request.error);
        };
    });
}

// ==================================================
// EXPORTAR PARA JSON
// ==================================================

async function exportarParaJSON() {
    const formularios = await buscarTodosFormularios();
    const json = JSON.stringify(formularios, null, 2);
    
    const blob = new Blob([json], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `extensionistas_${new Date().toISOString().split('T')[0]}.json`;
    a.click();
    URL.revokeObjectURL(url);
}

// ==================================================
// UTILITÁRIOS
// ==================================================

function gerarProtocolo() {
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
    return `EXT-${timestamp}-${random}`;
}

function formatarData(isoString) {
    if (!isoString) return '-';
    const data = new Date(isoString);
    return data.toLocaleString('pt-BR', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

// ==================================================
// ESTATÍSTICAS RÁPIDAS
// ==================================================

async function obterEstatisticas() {
    const formularios = await buscarTodosFormularios();
    const naoSincronizados = formularios.filter(f => !f.sincronizado).length;
    
    const municipios = new Set(formularios.map(f => f.municipio).filter(Boolean));
    
    const ultimos7Dias = formularios.filter(f => {
        const data = new Date(f.timestamp_fim);
        const hoje = new Date();
        const diff = hoje - data;
        return diff <= 7 * 24 * 60 * 60 * 1000;
    }).length;

    return {
        total: formularios.length,
        sincronizados: formularios.length - naoSincronizados,
        naoSincronizados: naoSincronizados,
        municipios: municipios.size,
        ultimos7Dias: ultimos7Dias
    };
}

// ==================================================
// SINCRONIZAÇÃO COM SERVIDOR
// ==================================================

async function sincronizarComServidor(urlAPI) {
    const naoSincronizados = await buscarNaoSincronizados();
    
    if (naoSincronizados.length === 0) {
        return { success: true, message: 'Nenhum formulário pendente' };
    }

    const resultados = {
        sucesso: 0,
        erro: 0,
        detalhes: []
    };

    for (const formulario of naoSincronizados) {
        try {
            const response = await fetch(urlAPI, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(formulario)
            });

            if (response.ok) {
                await marcarComoSincronizado(formulario.id);
                resultados.sucesso++;
                resultados.detalhes.push({ protocolo: formulario.protocolo, status: 'ok' });
            } else {
                resultados.erro++;
                resultados.detalhes.push({ protocolo: formulario.protocolo, status: 'erro', mensagem: await response.text() });
            }
        } catch (error) {
            resultados.erro++;
            resultados.detalhes.push({ protocolo: formulario.protocolo, status: 'erro', mensagem: error.message });
        }
    }

    return {
        success: true,
        total: naoSincronizados.length,
        sucesso: resultados.sucesso,
        erro: resultados.erro,
        detalhes: resultados.detalhes
    };
}

// ==================================================
// SINCRONIZAÇÃO COM SQL AZURE
// ==================================================

// Sincronizar um formulário específico com o servidor
async function sincronizarFormularioComAzure(formulario) {
    try {
        console.log('🔄 [SYNC] Iniciando sincronização:', formulario.protocolo);
        
        // Verificar se config existe
        if (typeof CONFIG === 'undefined' || !CONFIG.API_URL) {
            console.error('❌ [SYNC] CONFIG não encontrado!');
            throw new Error('Configuração da API não encontrada');
        }

        const url = CONFIG.API_URL + CONFIG.ENDPOINTS.SAVE;
        console.log('📤 [SYNC] URL:', url);
        console.log('📦 [SYNC] Enviando dados do formulário...');
        
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(formulario),
            signal: AbortSignal.timeout(CONFIG.TIMEOUT || 30000)
        });

        console.log('📥 [SYNC] Status da resposta:', response.status, response.statusText);

        if (!response.ok) {
            const errorText = await response.text();
            console.error('❌ [SYNC] Erro HTTP:', errorText);
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const result = await response.json();
        console.log('📋 [SYNC] Resultado da API:', result);
        
        if (result.success) {
            // Marcar como sincronizado no IndexedDB
            console.log('✅ [SYNC] API retornou sucesso, marcando como sincronizado...');
            await marcarComoSincronizado(formulario.protocolo);
            console.log(`✅ [SYNC] Formulário ${formulario.protocolo} sincronizado com Azure`);
            return { success: true, protocolo: formulario.protocolo };
        } else {
            console.error('❌ [SYNC] API retornou erro:', result.error);
            throw new Error(result.error || 'Erro desconhecido');
        }
    } catch (error) {
        console.error(`❌ [SYNC] Erro ao sincronizar ${formulario.protocolo}:`, error.message);
        console.error('❌ [SYNC] Stack:', error.stack);
        return { success: false, protocolo: formulario.protocolo, error: error.message };
    }
}

// Marcar formulário como sincronizado
async function marcarComoSincronizado(protocolo) {
    if (!db) await initDB();
    
    console.log('🏷️ [MARK] Marcando como sincronizado:', protocolo);
    
    return new Promise((resolve, reject) => {
        const transaction = db.transaction([STORE_NAME], 'readwrite');
        const objectStore = transaction.objectStore(STORE_NAME);
        const index = objectStore.index('protocolo');
        const request = index.get(protocolo);

        request.onsuccess = () => {
            const formulario = request.result;
            if (formulario) {
                console.log('📝 [MARK] Formulário encontrado, atualizando status...');
                formulario.sincronizado = true;
                formulario.data_sincronizacao = new Date().toISOString();
                
                const updateRequest = objectStore.put(formulario);
                updateRequest.onsuccess = () => {
                    console.log('✅ [MARK] Status atualizado com sucesso!');
                    resolve(true);
                };
                updateRequest.onerror = () => {
                    console.error('❌ [MARK] Erro ao atualizar:', updateRequest.error);
                    reject(updateRequest.error);
                };
            } else {
                console.error('❌ [MARK] Formulário não encontrado:', protocolo);
                reject(new Error('Formulário não encontrado'));
            }
        };

        request.onerror = () => {
            console.error('❌ [MARK] Erro ao buscar formulário:', request.error);
            reject(request.error);
        };
    });
}

// Sincronizar todos os formulários pendentes
async function sincronizarTodosComAzure() {
    try {
        console.log('🔄 Iniciando sincronização com SQL Azure...');
        
        // Verificar conexão
        if (!navigator.onLine) {
            console.log('⚠️ Sem conexão com a internet');
            return { success: false, error: 'Sem conexão' };
        }

        // Buscar formulários não sincronizados
        const formularios = await buscarNaoSincronizados();
        
        if (formularios.length === 0) {
            console.log('✅ Nenhum formulário pendente');
            return { success: true, sincronizados: 0 };
        }

        console.log(`📤 Sincronizando ${formularios.length} formulário(s)...`);
        
        const resultados = {
            sucesso: 0,
            erro: 0,
            detalhes: []
        };

        // Sincronizar cada formulário
        for (const form of formularios) {
            const resultado = await sincronizarFormularioComAzure(form);
            
            if (resultado.success) {
                resultados.sucesso++;
            } else {
                resultados.erro++;
            }
            
            resultados.detalhes.push(resultado);
            
            // Pequeno delay para não sobrecarregar
            await new Promise(resolve => setTimeout(resolve, 100));
        }

        console.log(`✅ Sincronização concluída: ${resultados.sucesso} sucesso, ${resultados.erro} erros`);
        
        return {
            success: true,
            total: formularios.length,
            sincronizados: resultados.sucesso,
            erros: resultados.erro,
            detalhes: resultados.detalhes
        };
    } catch (error) {
        console.error('❌ Erro na sincronização:', error);
        return { success: false, error: error.message };
    }
}

// Buscar formulários do servidor Azure
async function buscarFormulariosDoAzure(filtros = {}) {
    try {
        if (typeof CONFIG === 'undefined' || !CONFIG.API_URL) {
            throw new Error('Configuração da API não encontrada');
        }

        // Construir query string
        const params = new URLSearchParams();
        if (filtros.protocolo) params.append('protocolo', filtros.protocolo);
        if (filtros.municipio) params.append('municipio', filtros.municipio);
        if (filtros.limite) params.append('limite', filtros.limite);
        if (filtros.offset) params.append('offset', filtros.offset);

        const url = CONFIG.API_URL + CONFIG.ENDPOINTS.GET_ALL + '?' + params.toString();
        
        const response = await fetch(url, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            },
            signal: AbortSignal.timeout(CONFIG.TIMEOUT || 30000)
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const result = await response.json();
        
        if (result.success) {
            console.log(`✅ ${result.total} formulários carregados do Azure`);
            return result;
        } else {
            throw new Error(result.error || 'Erro desconhecido');
        }
    } catch (error) {
        console.error('❌ Erro ao buscar do Azure:', error.message);
        return { success: false, error: error.message };
    }
}

// ==================================================
// LOG DE ATIVIDADES
// ==================================================

console.log(`
╔════════════════════════════════════════╗
║  IndexedDB - Extensionistas EMATER-RO  ║
║  Versão 1.0 - 08/12/2025              ║
║  + SQL Azure Integration               ║
╚════════════════════════════════════════╝
`);

// ==================================================
// EXPORTAR FUNÇÕES GLOBALMENTE
// ==================================================
// Disponibilizar funções para uso em outros arquivos HTML

window.initDB = initDB;
window.salvarFormulario = salvarFormulario;
window.buscarTodosFormularios = buscarTodosFormularios;
window.buscarPorProtocolo = buscarPorProtocolo;
window.buscarNaoSincronizados = buscarNaoSincronizados;
window.marcarComoSincronizado = marcarComoSincronizado;
window.contarFormularios = contarFormularios;
window.limparTodosDados = limparTodosDados;
window.exportarParaJSON = exportarParaJSON;
window.gerarProtocolo = gerarProtocolo;
window.formatarData = formatarData;
window.obterEstatisticas = obterEstatisticas;
window.sincronizarComServidor = sincronizarComServidor;
window.sincronizarFormularioComAzure = sincronizarFormularioComAzure;
window.sincronizarTodosComAzure = sincronizarTodosComAzure;
window.buscarFormulariosDoAzure = buscarFormulariosDoAzure;

console.log('✅ Funções do db-extensionistas.js exportadas globalmente');
