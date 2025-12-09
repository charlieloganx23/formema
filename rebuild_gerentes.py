# -*- coding: utf-8 -*-
"""
Script para reconstruir os Eixos B, C, D e E do formulário gerentes.html
Após o incidente de perda de dados com o git checkout
"""

import re

# Ler o arquivo atual
with open('gerentes.html', 'r', encoding='utf-8') as f:
    content = f.read()

print("Arquivo lido. Tamanho:", len(content), "caracteres")

# ==================== EIXO B ====================
# Adicionar Q7-10 após a Q6 (após exemploInstrumento)

eixo_b_insert = '''
                    <!-- QUESTÃO 7: Plano anual/regional -->
                    <fieldset class="question-group">
                        <legend>7) Existe plano anual/regional de trabalho?</legend>
                        <div class="radio-group">
                            <label class="radio-label"><input type="radio" name="planoAnual" value="sim_aprovado"> <span>Sim, aprovado</span></label>
                            <label class="radio-label"><input type="radio" name="planoAnual" value="sim_elaboracao"> <span>Sim, em elaboração</span></label>
                            <label class="radio-label"><input type="radio" name="planoAnual" value="nao"> <span>Não</span></label>
                        </div>
                    </fieldset>

                    <!-- QUESTÃO 8: Participantes do plano -->
                    <fieldset class="question-group">
                        <legend>8) Quem participa da construção do plano? <span class="hint">(pode marcar mais de uma opção)</span></legend>
                        <div class="checkbox-group">
                            <label class="checkbox-label"><input type="checkbox" name="participantesPlano" value="gerencia_local"> <span>Gerência local</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="participantesPlano" value="tecnicos_extensionistas"> <span>Técnicos extensionistas</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="participantesPlano" value="prefeitura_secretaria"> <span>Prefeitura/Secretaria municipal</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="participantesPlano" value="sede_estadual"> <span>Sede estadual</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="participantesPlano" value="produtores_associacoes"> <span>Produtores/associações</span></label>
                        </div>
                    </fieldset>

                    <!-- QUESTÃO 9: Suficiência de recursos -->
                    <div class="question-group">
                        <label class="question-label">9) Avalie a suficiência de recursos:</label>
                        <p class="question-description">1 = muito insuficiente, 5 = totalmente suficiente</p>

                        <div style="margin-bottom: 1.5rem;">
                            <p style="font-weight: 500;">a) Pessoal técnico</p>
                            <div class="likert-scale">
                                <label class="likert-label"><input type="radio" name="suficiencia_pessoal" value="1"><span class="likert-number">1</span><span class="likert-text">Muito insuficiente</span></label>
                                <label class="likert-label"><input type="radio" name="suficiencia_pessoal" value="2"><span class="likert-number">2</span><span class="likert-text">Insuficiente</span></label>
                                <label class="likert-label"><input type="radio" name="suficiencia_pessoal" value="3"><span class="likert-number">3</span><span class="likert-text">Adequado</span></label>
                                <label class="likert-label"><input type="radio" name="suficiencia_pessoal" value="4"><span class="likert-number">4</span><span class="likert-text">Suficiente</span></label>
                                <label class="likert-label"><input type="radio" name="suficiencia_pessoal" value="5"><span class="likert-number">5</span><span class="likert-text">Totalmente suficiente</span></label>
                            </div>
                        </div>

                        <div style="margin-bottom: 1.5rem;">
                            <p style="font-weight: 500;">b) Veículo/transporte</p>
                            <div class="likert-scale">
                                <label class="likert-label"><input type="radio" name="suficiencia_veiculo" value="1"><span class="likert-number">1</span><span class="likert-text">Muito insuficiente</span></label>
                                <label class="likert-label"><input type="radio" name="suficiencia_veiculo" value="2"><span class="likert-number">2</span><span class="likert-text">Insuficiente</span></label>
                                <label class="likert-label"><input type="radio" name="suficiencia_veiculo" value="3"><span class="likert-number">3</span><span class="likert-text">Adequado</span></label>
                                <label class="likert-label"><input type="radio" name="suficiencia_veiculo" value="4"><span class="likert-number">4</span><span class="likert-text">Suficiente</span></label>
                                <label class="likert-label"><input type="radio" name="suficiencia_veiculo" value="5"><span class="likert-number">5</span><span class="likert-text">Totalmente suficiente</span></label>
                            </div>
                        </div>

                        <div style="margin-bottom: 1.5rem;">
                            <p style="font-weight: 500;">c) Estrutura física (escritório)</p>
                            <div class="likert-scale">
                                <label class="likert-label"><input type="radio" name="suficiencia_estrutura" value="1"><span class="likert-number">1</span><span class="likert-text">Muito insuficiente</span></label>
                                <label class="likert-label"><input type="radio" name="suficiencia_estrutura" value="2"><span class="likert-number">2</span><span class="likert-text">Insuficiente</span></label>
                                <label class="likert-label"><input type="radio" name="suficiencia_estrutura" value="3"><span class="likert-number">3</span><span class="likert-text">Adequado</span></label>
                                <label class="likert-label"><input type="radio" name="suficiencia_estrutura" value="4"><span class="likert-number">4</span><span class="likert-text">Suficiente</span></label>
                                <label class="likert-label"><input type="radio" name="suficiencia_estrutura" value="5"><span class="likert-number">5</span><span class="likert-text">Totalmente suficiente</span></label>
                            </div>
                        </div>

                        <div style="margin-bottom: 1.5rem;">
                            <p style="font-weight: 500;">d) Equipamentos (computadores, celulares)</p>
                            <div class="likert-scale">
                                <label class="likert-label"><input type="radio" name="suficiencia_equipamentos" value="1"><span class="likert-number">1</span><span class="likert-text">Muito insuficiente</span></label>
                                <label class="likert-label"><input type="radio" name="suficiencia_equipamentos" value="2"><span class="likert-number">2</span><span class="likert-text">Insuficiente</span></label>
                                <label class="likert-label"><input type="radio" name="suficiencia_equipamentos" value="3"><span class="likert-number">3</span><span class="likert-text">Adequado</span></label>
                                <label class="likert-label"><input type="radio" name="suficiencia_equipamentos" value="4"><span class="likert-number">4</span><span class="likert-text">Suficiente</span></label>
                                <label class="likert-label"><input type="radio" name="suficiencia_equipamentos" value="5"><span class="likert-number">5</span><span class="likert-text">Totalmente suficiente</span></label>
                            </div>
                        </div>
                    </div>

                    <!-- QUESTÃO 10: Efeitos da carência -->
                    <fieldset class="question-group">
                        <legend>10) Caso existam carências, qual o principal efeito? <span class="hint">(marcar até 3)</span></legend>
                        <div class="checkbox-group" data-max-check="3">
                            <label class="checkbox-label"><input type="checkbox" name="efeitosCarencia" value="reducao_visitas"> <span>Redução de visitas</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="efeitosCarencia" value="reducao_capacitacoes"> <span>Redução de capacitações</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="efeitosCarencia" value="menor_acompanhamento"> <span>Menor acompanhamento dos produtores</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="efeitosCarencia" value="falta_diagnosticos"> <span>Falta de diagnósticos e planejamento</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="efeitosCarencia" value="desmotivacao_equipe"> <span>Desmotivação da equipe</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="efeitosCarencia" value="dificuldade_articulacao"> <span>Dificuldade de articulação com parceiros</span></label>
                            <label class="checkbox-label">
                                <input type="checkbox" name="efeitosCarencia" value="outro">
                                <span>Outro: <input type="text" name="efeitosCarenciaOutro" class="input-field" placeholder="Especifique" style="margin-top: 8px; width: 100%;" /></span>
                            </label>
                        </div>
                        <p class="text-muted">Máximo de 3 opções</p>
                    </fieldset>
'''

# Buscar o ponto de inserção (após exemploInstrumento)
pattern_eixo_b = r'(<textarea id="exemploInstrumento"[^>]*>.*?</textarea>\s*</div>)'
match = re.search(pattern_eixo_b, content, re.DOTALL)
if match:
    insert_pos = match.end()
    content = content[:insert_pos] + eixo_b_insert + content[insert_pos:]
    print("✓ Eixo B (Q7-10) inserido")
else:
    print("✗ ERRO: Não foi possível encontrar ponto de inserção do Eixo B")

# Salvar arquivo intermediário para debug
with open('gerentes_step1.html', 'w', encoding='utf-8') as f:
    f.write(content)
print("Arquivo intermediário salvo: gerentes_step1.html")

# ==================== EIXO C ====================
# Substituir toda a Etapa 4 (section-4) com as questões Q11-16

eixo_c_new = '''                <!-- ETAPA 4: EIXO C -->
                <section class="form-section" id="section-4" data-step="4">
                    <div class="section-header">
                        <h3>Eixo C – Parcerias e Participação em Fóruns</h3>
                        <p class="text-muted">Tempo estimado: 5 minutos</p>
                    </div>

                    <!-- QUESTÃO 11: Parceiros relevantes -->
                    <fieldset class="question-group">
                        <legend>11) Quais parceiros são mais relevantes para sua unidade? <span class="hint">(marcar até 3)</span></legend>
                        <div class="checkbox-group" data-max-check="3">
                            <label class="checkbox-label"><input type="checkbox" name="parceirosRelevantes" value="prefeituras"> <span>Prefeituras</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="parceirosRelevantes" value="cooperativas"> <span>Cooperativas</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="parceirosRelevantes" value="associacoes"> <span>Associações</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="parceirosRelevantes" value="sindicatos"> <span>Sindicatos rurais</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="parceirosRelevantes" value="universidades"> <span>Universidades/Institutos pesquisa</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="parceirosRelevantes" value="ongs"> <span>ONGs</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="parceirosRelevantes" value="empresas_privadas"> <span>Empresas privadas</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="parceirosRelevantes" value="senar"> <span>SENAR</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="parceirosRelevantes" value="credito_rural"> <span>Bancos/crédito rural</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="parceirosRelevantes" value="secretarias_estaduais"> <span>Secretarias estaduais</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="parceirosRelevantes" value="mda_incra"> <span>MDA/INCRA</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="parceirosRelevantes" value="conab"> <span>CONAB</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="parceirosRelevantes" value="conselho_municipal"> <span>Conselho Municipal Desenvolvimento Rural</span></label>
                            <label class="checkbox-label">
                                <input type="checkbox" name="parceirosRelevantes" value="outro">
                                <span>Outro: <input type="text" name="parceirosRelevantesOutro" class="input-field" placeholder="Especifique" style="margin-top: 8px; width: 100%;" /></span>
                            </label>
                        </div>
                        <p class="text-muted">Máximo de 3 opções</p>
                    </fieldset>

                    <!-- QUESTÃO 12: Levantamento PNAE -->
                    <fieldset class="question-group">
                        <legend>12) A unidade faz levantamento regular de oportunidades de PNAE?</legend>
                        <div class="radio-group">
                            <label class="radio-label"><input type="radio" name="levantamentoPNAE" value="sim_sistematico"> <span>Sim, de forma sistemática</span></label>
                            <label class="radio-label"><input type="radio" name="levantamentoPNAE" value="sim_esporadico"> <span>Sim, esporadicamente</span></label>
                            <label class="radio-label"><input type="radio" name="levantamentoPNAE" value="nao"> <span>Não</span></label>
                        </div>
                    </fieldset>

                    <div class="question-group" id="instrumentosPNAE" style="display: none;">
                        <label class="question-label">Caso sim, que instrumentos utiliza?</label>
                        <textarea name="instrumentosPNAE" class="input-field" rows="3" placeholder="Descreva os instrumentos utilizados"></textarea>
                    </div>

                    <!-- QUESTÃO 13: Frequência fóruns -->
                    <fieldset class="question-group">
                        <legend>13) Com que frequência sua unidade participa de fóruns, conselhos ou colegiados territoriais?</legend>
                        <div class="radio-group">
                            <label class="radio-label"><input type="radio" name="frequenciaForuns" value="sempre"> <span>Sempre</span></label>
                            <label class="radio-label"><input type="radio" name="frequenciaForuns" value="frequentemente"> <span>Frequentemente</span></label>
                            <label class="radio-label"><input type="radio" name="frequenciaForuns" value="as_vezes"> <span>Às vezes</span></label>
                            <label class="radio-label"><input type="radio" name="frequenciaForuns" value="raramente"> <span>Raramente</span></label>
                            <label class="radio-label"><input type="radio" name="frequenciaForuns" value="nunca"> <span>Nunca</span></label>
                        </div>
                    </fieldset>

                    <!-- QUESTÃO 14: Natureza participação -->
                    <fieldset class="question-group">
                        <legend>14) Qual a natureza da participação nesses espaços? <span class="hint">(pode marcar mais de uma)</span></legend>
                        <div class="checkbox-group">
                            <label class="checkbox-label"><input type="checkbox" name="naturezaParticipacao" value="apresentacao_projetos"> <span>Apresentação de projetos/demandas</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="naturezaParticipacao" value="articulacao_parcerias"> <span>Articulação de parcerias</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="naturezaParticipacao" value="assessoria_tecnica"> <span>Assessoria técnica</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="naturezaParticipacao" value="apenas_presenca"> <span>Apenas presença institucional</span></label>
                        </div>
                    </fieldset>

                    <!-- QUESTÃO 15: Quantidade proposições -->
                    <fieldset class="question-group">
                        <legend>15) Quantas proposições/iniciativas sua unidade apresentou nesses espaços no último ano?</legend>
                        <div class="radio-group">
                            <label class="radio-label"><input type="radio" name="quantidadeProposicoes" value="nenhuma"> <span>Nenhuma</span></label>
                            <label class="radio-label"><input type="radio" name="quantidadeProposicoes" value="1-3"> <span>1 a 3</span></label>
                            <label class="radio-label"><input type="radio" name="quantidadeProposicoes" value="4-6"> <span>4 a 6</span></label>
                            <label class="radio-label"><input type="radio" name="quantidadeProposicoes" value="mais_6"> <span>Mais de 6</span></label>
                        </div>
                    </fieldset>

                    <!-- QUESTÃO 16: Percepção efetividade -->
                    <fieldset class="question-group">
                        <legend>16) Como você avalia a efetividade dessas proposições?</legend>
                        <div class="radio-group">
                            <label class="radio-label"><input type="radio" name="efetividadeProposicoes" value="baixa"> <span>Baixa</span></label>
                            <label class="radio-label"><input type="radio" name="efetividadeProposicoes" value="media"> <span>Média</span></label>
                            <label class="radio-label"><input type="radio" name="efetividadeProposicoes" value="alta"> <span>Alta</span></label>
                        </div>
                    </fieldset>

                    <div class="question-group">
                        <label for="comentarioC" class="question-label">
                            Gostaria de registrar algum comentário ou descrição sobre sua experiência relacionada a esse bloco?
                        </label>
                        <textarea id="comentarioC" name="comentarioC" class="input-field" rows="4" placeholder="Escreva aqui (opcional)"></textarea>
                    </div>

                    <div class="navigation-buttons">
                        <button type="button" class="btn btn-secondary" onclick="previousSection()">Voltar</button>
                        <button type="button" class="btn btn-primary" onclick="nextSection()">Próximo</button>
                    </div>
                </section>
'''

# Substituir toda a section-4
pattern_section4 = r'(\s*<!-- ETAPA 4:.*?-->.*?<section class="form-section" id="section-4".*?</section>)'
match_c = re.search(pattern_section4, content, re.DOTALL)
if match_c:
    content = content[:match_c.start()] + eixo_c_new + content[match_c.end():]
    print("✓ Eixo C (Q11-16) substituído")
else:
    print("✗ ERRO: Não foi possível encontrar section-4 para substituir")

# Salvar progresso
with open('gerentes_step2.html', 'w', encoding='utf-8') as f:
    f.write(content)
print("Arquivo intermediário salvo: gerentes_step2.html")

# ==================== EIXO D ====================
# Substituir toda a section-5 com as questões Q17-20

eixo_d_new = '''
                <!-- ETAPA 5: EIXO D -->
                <section class="form-section" id="section-5" data-step="5">
                    <div class="section-header">
                        <h3>Eixo D – Produção, Demanda e Mercado</h3>
                        <p class="text-muted">Tempo estimado: 5 minutos</p>
                    </div>

                    <!-- QUESTÃO 17: Diagnósticos de demanda -->
                    <fieldset class="question-group">
                        <legend>17) Sua unidade produz diagnósticos de demanda ou estudos de vocações locais?</legend>
                        <div class="radio-group">
                            <label class="radio-label"><input type="radio" name="diagnosticoDemanda" value="sim_documentos"> <span>Sim, com documentos disponíveis</span></label>
                            <label class="radio-label"><input type="radio" name="diagnosticoDemanda" value="sim_informal"> <span>Sim, informal</span></label>
                            <label class="radio-label"><input type="radio" name="diagnosticoDemanda" value="nao"> <span>Não</span></label>
                        </div>
                    </fieldset>

                    <div class="question-group" id="instrumentosDiagnostico" style="display: none;">
                        <label class="question-label">Caso sim, quais instrumentos são produzidos?</label>
                        <div class="checkbox-group">
                            <label class="checkbox-label"><input type="checkbox" name="instrumentosDiagnostico" value="estudos_tecnicos"> <span>Estudos técnicos</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="instrumentosDiagnostico" value="levantamento_mercado"> <span>Levantamento de mercado</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="instrumentosDiagnostico" value="mapas_vocacoes"> <span>Mapas de vocações</span></label>
                            <label class="checkbox-label">
                                <input type="checkbox" name="instrumentosDiagnostico" value="outro">
                                <span>Outro: <input type="text" name="instrumentosDiagnosticoOutro" class="input-field" placeholder="Especifique" style="margin-top: 8px; width: 100%;" /></span>
                            </label>
                        </div>
                    </div>

                    <!-- QUESTÃO 18: Instrumentos apoio comercialização -->
                    <fieldset class="question-group">
                        <legend>18) Que instrumentos ou ações de apoio à comercialização existem na sua unidade? <span class="hint">(marcar todos que se aplicam)</span></legend>
                        <div class="checkbox-group">
                            <label class="checkbox-label"><input type="checkbox" name="apoioComercializacao" value="estruturacao_paa_pnae"> <span>Estruturação de projeto e acompanhamento para PAA/PNAE</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="apoioComercializacao" value="acesso_compradores_privados"> <span>Facilitador de acesso a compradores privados</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="apoioComercializacao" value="apoio_embalagens_rotulos"> <span>Apoio em embalagens/rótulos</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="apoioComercializacao" value="organizacao_feiras"> <span>Organização de feiras locais</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="apoioComercializacao" value="formacao_grupos"> <span>Formação de grupos de comercialização</span></label>
                            <label class="checkbox-label">
                                <input type="checkbox" name="apoioComercializacao" value="outro">
                                <span>Outro: <input type="text" name="apoioComercializacaoOutro" class="input-field" placeholder="Especifique" style="margin-top: 8px; width: 100%;" /></span>
                            </label>
                        </div>
                    </fieldset>

                    <!-- QUESTÃO 19: Relacionamento compradores -->
                    <div class="question-group">
                        <label class="question-label">19) Avalie o relacionamento com compradores públicos e privados:</label>
                        <p class="question-description">1 = péssimo, 5 = excelente</p>
                        <div class="likert-scale">
                            <label class="likert-label"><input type="radio" name="relacionamentoCompradores" value="1"><span class="likert-number">1</span><span class="likert-text">Péssimo</span></label>
                            <label class="likert-label"><input type="radio" name="relacionamentoCompradores" value="2"><span class="likert-number">2</span><span class="likert-text">Ruim</span></label>
                            <label class="likert-label"><input type="radio" name="relacionamentoCompradores" value="3"><span class="likert-number">3</span><span class="likert-text">Regular</span></label>
                            <label class="likert-label"><input type="radio" name="relacionamentoCompradores" value="4"><span class="likert-number">4</span><span class="likert-text">Bom</span></label>
                            <label class="likert-label"><input type="radio" name="relacionamentoCompradores" value="5"><span class="likert-number">5</span><span class="likert-text">Excelente</span></label>
                        </div>
                    </div>

                    <!-- QUESTÃO 20: Barreiras relacionamento -->
                    <fieldset class="question-group">
                        <legend>20) Quais as principais barreiras no relacionamento? <span class="hint">(marcar até 3)</span></legend>
                        <div class="checkbox-group" data-max-check="3">
                            <label class="checkbox-label"><input type="checkbox" name="barreirasRelacionamento" value="documentacao"> <span>Documentação</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="barreirasRelacionamento" value="qualidade"> <span>Qualidade</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="barreirasRelacionamento" value="volume"> <span>Volume</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="barreirasRelacionamento" value="logistica"> <span>Logística</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="barreirasRelacionamento" value="preco"> <span>Preço</span></label>
                            <label class="checkbox-label">
                                <input type="checkbox" name="barreirasRelacionamento" value="outro">
                                <span>Outro: <input type="text" name="barreirasRelacionamentoOutro" class="input-field" placeholder="Especifique" style="margin-top: 8px; width: 100%;" /></span>
                            </label>
                        </div>
                        <p class="text-muted">Máximo de 3 opções</p>
                    </fieldset>

                    <div class="question-group">
                        <label for="comentarioD" class="question-label">
                            Gostaria de registrar algum comentário ou descrição sobre sua experiência relacionada a esse bloco?
                        </label>
                        <textarea id="comentarioD" name="comentarioD" class="input-field" rows="4" placeholder="Escreva aqui (opcional)"></textarea>
                    </div>

                    <div class="navigation-buttons">
                        <button type="button" class="btn btn-secondary" onclick="previousSection()">Voltar</button>
                        <button type="button" class="btn btn-primary" onclick="nextSection()">Próximo</button>
                    </div>
                </section>
'''

# Substituir toda a section-5
pattern_section5 = r'(\s*<!-- ETAPA 5:.*?-->.*?<section class="form-section" id="section-5".*?</section>)'
match_d = re.search(pattern_section5, content, re.DOTALL)
if match_d:
    content = content[:match_d.start()] + eixo_d_new + content[match_d.end():]
    print("✓ Eixo D (Q17-20) substituído")
else:
    print("✗ ERRO: Não foi possível encontrar section-5 para substituir")

# Salvar progresso
with open('gerentes_step3.html', 'w', encoding='utf-8') as f:
    f.write(content)
print("Arquivo intermediário salvo: gerentes_step3.html")

# ==================== EIXO E ====================
# Substituir toda a section-6 com as questões Q21-26

eixo_e_new = '''
                <!-- ETAPA 6: EIXO E + FINAL -->
                <section class="form-section" id="section-6" data-step="6">
                    <div class="section-header">
                        <h3>Eixo E – Monitoramento e Avaliação de Resultados</h3>
                        <p class="text-muted">Tempo estimado: 5 minutos</p>
                    </div>

                    <!-- QUESTÃO 21: Indicadores usados -->
                    <fieldset class="question-group">
                        <legend>21) Quais indicadores são usados rotineiramente para avaliar o desempenho da unidade? <span class="hint">(marcar todos que se aplicam)</span></legend>
                        <div class="checkbox-group">
                            <label class="checkbox-label"><input type="checkbox" name="indicadoresDesempenho" value="visitas_tecnicas"> <span>Nº de visitas técnicas/ano</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="indicadoresDesempenho" value="produtores_atendidos"> <span>Nº de produtores atendidos</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="indicadoresDesempenho" value="capacitacoes"> <span>Nº de capacitações</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="indicadoresDesempenho" value="vendas_assistidas"> <span>Volume/Valor de vendas assistidas</span></label>
                            <label class="checkbox-label"><input type="checkbox" name="indicadoresDesempenho" value="praticas_sustentaveis"> <span>Adoção de práticas sustentáveis</span></label>
                            <label class="checkbox-label">
                                <input type="checkbox" name="indicadoresDesempenho" value="outro">
                                <span>Outro: <input type="text" name="indicadoresDesempenhoOutro" class="input-field" placeholder="Descreva" style="margin-top: 8px; width: 100%;" /></span>
                            </label>
                        </div>
                    </fieldset>

                    <!-- QUESTÃO 22: Formalização de relatórios -->
                    <fieldset class="question-group">
                        <legend>22) Esses indicadores estão formalizados em relatórios periódicos?</legend>
                        <div class="radio-group">
                            <label class="radio-label"><input type="radio" name="indicadoresFormalizados" value="sim"> <span>Sim</span></label>
                            <label class="radio-label"><input type="radio" name="indicadoresFormalizados" value="parcialmente"> <span>Parcialmente</span></label>
                            <label class="radio-label"><input type="radio" name="indicadoresFormalizados" value="nao"> <span>Não</span></label>
                        </div>
                    </fieldset>

                    <!-- QUESTÃO 23: Indicadores de efetividade -->
                    <fieldset class="question-group">
                        <legend>23) Existem indicadores de efetividade (mudança efetiva na vida dos produtores)?</legend>
                        <div class="radio-group">
                            <label class="radio-label"><input type="radio" name="indicadoresEfetividade" value="sim"> <span>Sim</span></label>
                            <label class="radio-label"><input type="radio" name="indicadoresEfetividade" value="parcialmente"> <span>Parcialmente</span></label>
                            <label class="radio-label"><input type="radio" name="indicadoresEfetividade" value="nao"> <span>Não</span></label>
                        </div>
                    </fieldset>

                    <div class="question-group" id="indicadoresEfetividadeQuais" style="display: none;">
                        <label class="question-label">Caso sim, quais indicadores?</label>
                        <textarea name="indicadoresEfetividadeQuais" class="input-field" rows="3" placeholder="Descreva os indicadores de efetividade"></textarea>
                    </div>

                    <!-- QUESTÃO 24: Frequência influência indicadores -->
                    <fieldset class="question-group">
                        <legend>24) Com que frequência esses indicadores influenciam decisões de planejamento?</legend>
                        <div class="radio-group">
                            <label class="radio-label"><input type="radio" name="frequenciaInfluencia" value="sempre"> <span>Sempre</span></label>
                            <label class="radio-label"><input type="radio" name="frequenciaInfluencia" value="frequentemente"> <span>Frequentemente</span></label>
                            <label class="radio-label"><input type="radio" name="frequenciaInfluencia" value="as_vezes"> <span>Às vezes</span></label>
                            <label class="radio-label"><input type="radio" name="frequenciaInfluencia" value="raramente"> <span>Raramente</span></label>
                            <label class="radio-label"><input type="radio" name="frequenciaInfluencia" value="nunca"> <span>Nunca</span></label>
                        </div>
                    </fieldset>

                    <!-- QUESTÃO 25: Capacidade acompanhamento -->
                    <div class="question-group">
                        <label class="question-label">25) Avalie a capacidade da unidade para fazer acompanhamento e avaliação:</label>
                        <p class="question-description">1 = muito fraca, 5 = muito robusta</p>
                        <div class="likert-scale">
                            <label class="likert-label"><input type="radio" name="capacidadeAcompanhamento" value="1"><span class="likert-number">1</span><span class="likert-text">Muito fraca</span></label>
                            <label class="likert-label"><input type="radio" name="capacidadeAcompanhamento" value="2"><span class="likert-number">2</span><span class="likert-text">Fraca</span></label>
                            <label class="likert-label"><input type="radio" name="capacidadeAcompanhamento" value="3"><span class="likert-number">3</span><span class="likert-text">Moderada</span></label>
                            <label class="likert-label"><input type="radio" name="capacidadeAcompanhamento" value="4"><span class="likert-number">4</span><span class="likert-text">Robusta</span></label>
                            <label class="likert-label"><input type="radio" name="capacidadeAcompanhamento" value="5"><span class="likert-number">5</span><span class="likert-text">Muito robusta</span></label>
                        </div>
                    </div>

                    <!-- QUESTÃO 26: Limitações acompanhamento -->
                    <div class="question-group">
                        <label for="limitacoesAcompanhamento" class="question-label">
                            26) Descreva as principais limitações da unidade para fazer acompanhamento e avaliação:
                        </label>
                        <textarea id="limitacoesAcompanhamento" name="limitacoesAcompanhamento" class="input-field" rows="4" placeholder="Descreva as limitações"></textarea>
                    </div>

                    <div class="question-group">
                        <label for="comentarioE" class="question-label">
                            Gostaria de registrar algum comentário ou descrição sobre sua experiência relacionada a esse bloco?
                        </label>
                        <textarea id="comentarioE" name="comentarioE" class="input-field" rows="4" placeholder="Escreva aqui (opcional)"></textarea>
                    </div>

                    <div class="navigation-buttons">
                        <button type="button" class="btn btn-secondary" onclick="previousSection()">Voltar</button>
                        <button type="submit" class="btn btn-primary">Enviar Formulário</button>
                    </div>
                </section>
'''

# Substituir toda a section-6
pattern_section6 = r'(\s*<!-- ETAPA 6:.*?-->.*?<section class="form-section" id="section-6".*?</section>)'
match_e = re.search(pattern_section6, content, re.DOTALL)
if match_e:
    content = content[:match_e.start()] + eixo_e_new + content[match_e.end():]
    print("✓ Eixo E (Q21-26) substituído")
else:
    print("✗ ERRO: Não foi possível encontrar section-6 para substituir")

# Salvar arquivo final
with open('gerentes.html', 'w', encoding='utf-8') as f:
    f.write(content)
print("\n✅ ARQUIVO FINAL SALVO: gerentes.html")
print(f"Tamanho final: {len(content)} caracteres")
print("\n📋 RESUMO:")
print("  ✓ Eixo B (Q7-10): Planejamento e Recursos")
print("  ✓ Eixo C (Q11-16): Parcerias e Fóruns")
print("  ✓ Eixo D (Q17-20): Produção, Demanda e Mercado")
print("  ✓ Eixo E (Q21-26): Monitoramento e Avaliação")
print("\nPróximo passo: Adicionar JavaScript para campos condicionais (Q12, Q17, Q23)")
