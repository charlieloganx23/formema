$arquivo = "c:\Users\darkf\OneDrive\Documentos\formema\index.html"
$content = [System.IO.File]::ReadAllText($arquivo, [System.Text.Encoding]::UTF8)

# Encontrar início do Eixo E
$inicioComment = "<!-- ETAPA 6: EIXO E + FINAL -->"
$inicioPos = $content.IndexOf($inicioComment)
$fimPos = $content.IndexOf("</form>", $inicioPos)

Write-Host "Início: $inicioPos, Fim: $fimPos"

# Novo conteúdo Eixo E
$novoEixoE = @"
<!-- ETAPA 6: EIXO E + FINAL -->
                <section class="form-section" id="section-6" data-step="6">
                    <div class="section-header">
                        <h3>Eixo E – Monitoramento e Avaliação de Resultados</h3>
                        <p class="text-muted">Tempo estimado: 6 minutos</p>
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
                                <span>Outro: <input type="text" name="indicadoresDesempenhoOutro" class="input-field" placeholder="Descreva" style="margin-top: 8px;" /></span>
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
                        <legend>23) São utilizados indicadores de efetividade, ou seja, consegue verificar o impacto do trabalho da Emater na vida do pequeno produtor?</legend>
                        <div class="radio-group">
                            <label class="radio-label"><input type="radio" name="indicadoresEfetividade" value="sim"> <span>Sim</span></label>
                            <label class="radio-label"><input type="radio" name="indicadoresEfetividade" value="parcialmente"> <span>Parcialmente</span></label>
                            <label class="radio-label"><input type="radio" name="indicadoresEfetividade" value="nao"> <span>Não</span></label>
                        </div>
                    </fieldset>

                    <!-- SUBQUESTÃO 23: Quais indicadores -->
                    <div class="question-group">
                        <label class="question-label">Caso Sim, quais são utilizados?</label>
                        <textarea name="indicadoresEfetividadeQuais" class="input-field" rows="3" placeholder="Descreva os indicadores de efetividade utilizados"></textarea>
                    </div>

                    <!-- QUESTÃO 24: Frequência de influência -->
                    <fieldset class="question-group">
                        <legend>24) Com que frequência os indicadores ou relatórios influenciam decisões de replanejamento das ações locais?</legend>
                        <div class="radio-group">
                            <label class="radio-label"><input type="radio" name="frequenciaInfluencia" value="sempre"> <span>Sempre</span></label>
                            <label class="radio-label"><input type="radio" name="frequenciaInfluencia" value="frequentemente"> <span>Frequentemente</span></label>
                            <label class="radio-label"><input type="radio" name="frequenciaInfluencia" value="as_vezes"> <span>Às vezes</span></label>
                            <label class="radio-label"><input type="radio" name="frequenciaInfluencia" value="raramente"> <span>Raramente</span></label>
                            <label class="radio-label"><input type="radio" name="frequenciaInfluencia" value="nunca"> <span>Nunca</span></label>
                        </div>
                    </fieldset>

                    <!-- QUESTÃO 25: Capacidade de acompanhamento -->
                    <div class="question-group">
                        <label class="question-label">25) Avalie a capacidade da Emater-RO de acompanhamento de impactos gerados junto aos pequenos agricultores:</label>
                        <p class="question-description">1 = muito fraca, 5 = muito robusta</p>
                        <div class="likert-scale">
                            <label class="likert-label">
                                <input type="radio" name="capacidadeAcompanhamento" value="1">
                                <span class="likert-number">1</span>
                                <span class="likert-text">Muito fraca</span>
                            </label>
                            <label class="likert-label">
                                <input type="radio" name="capacidadeAcompanhamento" value="2">
                                <span class="likert-number">2</span>
                                <span class="likert-text">Fraca</span>
                            </label>
                            <label class="likert-label">
                                <input type="radio" name="capacidadeAcompanhamento" value="3">
                                <span class="likert-number">3</span>
                                <span class="likert-text">Regular</span>
                            </label>
                            <label class="likert-label">
                                <input type="radio" name="capacidadeAcompanhamento" value="4">
                                <span class="likert-number">4</span>
                                <span class="likert-text">Robusta</span>
                            </label>
                            <label class="likert-label">
                                <input type="radio" name="capacidadeAcompanhamento" value="5">
                                <span class="likert-number">5</span>
                                <span class="likert-text">Muito robusta</span>
                            </label>
                        </div>
                    </div>

                    <!-- QUESTÃO 26: Limitações -->
                    <div class="question-group">
                        <label class="question-label">26) Quais as principais limitações para acompanhar os impactos gerados?</label>
                        <textarea name="limitacoesAcompanhamento" class="input-field" rows="4" placeholder="Descreva as principais limitações"></textarea>
                    </div>

                    <!-- COMENTÁRIO FINAL -->
                    <div class="question-group">
                        <label for="comentarioFinal" class="question-label">
                            Gostaria de registrar algum comentário adicional sobre sua experiência como extensionista da Emater?
                        </label>
                        <textarea id="comentarioFinal" name="comentarioFinal" class="input-field" rows="4" placeholder="Escreva aqui (opcional)"></textarea>
                    </div>

                    <div class="navigation-buttons">
                        <button type="button" class="btn btn-secondary" onclick="previousSection()">Voltar</button>
                        <button type="submit" class="btn btn-primary">Enviar respostas</button>
                    </div>
                </section>
"@

# Substituir
$antes = $content.Substring(0, $inicioPos)
$depois = $content.Substring($fimPos)
$novoConteudo = $antes + $novoEixoE + $depois

[System.IO.File]::WriteAllText($arquivo, $novoConteudo, [System.Text.Encoding]::UTF8)
Write-Host "Eixo E substituído com sucesso!"
