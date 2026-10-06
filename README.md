# Tailscale para WD My Cloud EX2 Ultra (My Cloud OS 5)

Criei este pacote porque queria acessar os arquivos do meu My Cloud EX2 Ultra fora de casa sem depender do mycloud.com, sem abrir portas no roteador e sem comprar outro equipamento só para fazer VPN. A WD não oferece mais um app de desktop para esse modelo e o OS 5 removeu o WebDAV, então a solução foi colocar a VPN dentro do próprio NAS.

O resultado é um app instalável pelo painel do My Cloud que roda o [Tailscale](https://tailscale.com) diretamente no NAS. Com ele, você mapeia os compartilhamentos no Windows Explorer (ou no Finder) de qualquer lugar, como se estivesse na rede de casa.

> **Projeto não oficial.** Não tem vínculo com a Western Digital nem com a Tailscale Inc. Use por sua conta e risco.

## Por que Tailscale

- **Funciona atrás de CGNAT.** Muitas operadoras no Brasil não entregam IP público (no painel do My Cloud aparece "Tipo de conexão: Relay"). O Tailscale não precisa de redirecionamento de portas.
- **Nada exposto na internet.** O NAS só fica acessível para os dispositivos da sua conta Tailscale.
- **Gratuito** para uso pessoal.

## Como funciona

- Na instalação, o próprio NAS baixa o Tailscale oficial de `pkgs.tailscale.com` e confere o SHA-256 publicado pela Tailscale. O binário não é redistribuído neste repositório.
- O Tailscale roda em modo *userspace networking*, sem depender de módulo `tun` no kernel do NAS. Conexões ao IP `100.x` do NAS chegam aos serviços locais (SMB, painel web).
- O app sobe sozinho a cada boot, como qualquer app do painel.
- O login fica salvo em `/mnt/HD/HD_a2/.systemfile/tailscale`, no volume de dados, e sobrevive a reboots e reinstalações.
- Um painel do Tailscale fica disponível só na rede local, na porta `5252`, para fazer login e ver o status.

## Compatibilidade

| Modelo | Firmware | Status |
|---|---|---|
| My Cloud EX2 Ultra | My Cloud OS 5 (5.x) | Alvo do pacote |

Outros modelos ARM com OS 5 podem funcionar gerando o pacote com o nome do modelo (veja "Gerar o pacote"), mas não foram testados.

## Instalação

1. Crie uma conta gratuita em [tailscale.com](https://tailscale.com).
2. Baixe o `.bin` na página de [Releases](../../releases) ou gere você mesmo (veja abaixo).
3. No painel do My Cloud, vá em **Apps → Instalar app manualmente** e selecione o `.bin`. O NAS precisa estar com acesso à internet.
4. Abra o app **Tailscale** no painel e clique em **Abrir painel do Tailscale** (`http://<ip-do-nas>:5252`). Faça login com a sua conta.
5. Instale o Tailscale no notebook ou celular e entre com a mesma conta.
6. Fora de casa, com o Tailscale ligado, acesse `\\<ip-100.x-do-NAS>\<compartilhamento>`. O IP `100.x` aparece no painel do Tailscale.

### Se o painel da porta 5252 não abrir

Ative o SSH no painel do My Cloud e rode:

```sh
/mnt/HD/HD_a2/Nas_Prog/tailscale/bin/tailscale --socket=/var/run/tailscale/tailscaled.sock up
```

O comando mostra um link de login.

## Atualizar o Tailscale

Via SSH:

```sh
sh /mnt/HD/HD_a2/Nas_Prog/tailscale/update.sh
```

## Logs

- Instalação e inicialização: `/tmp/tailscale_apkg.log`
- Serviço do Tailscale: `/tmp/tailscaled.log`
- Painel web: `/tmp/tailscale_web.log`

Os logs ficam em `/tmp` e são apagados no reboot.

## Desinstalar

Remova o app pelo painel do My Cloud. Para desvincular o NAS da sua conta de vez, apague também `/mnt/HD/HD_a2/.systemfile/tailscale` e remova o dispositivo no painel administrativo do Tailscale.

## Gerar o pacote

Em Linux x86_64 com `libxml2` instalado:

```sh
./build.sh
```

O `.bin` é gerado em `dist/`. Para outro modelo, troque `MyCloudEX2Ultra` em `build.sh`.

## Estrutura

```
tailscale/         scripts do app (formato APKG do My Cloud OS 5)
  apkg.rc          metadados do app
  common.sh        variáveis compartilhadas
  install.sh       instalação (copia o app e baixa o Tailscale)
  update.sh        baixa/atualiza o Tailscale com verificação SHA-256
  init.sh          liga a página do app no painel
  start.sh/stop.sh inicia e para o serviço
  remove.sh        desinstalação
  web/             página do app no painel
  cacert.pem       certificados raiz para o download via HTTPS
tools/mksapkg-OS5  empacotador da comunidade WD
tools/openssl-legacy.cnf  habilita a cifra antiga que o empacotador usa (OpenSSL 3)
build.sh           gera o .bin
```

## Créditos

Este projeto só foi possível graças a trabalhos de outras pessoas:

- **[WDCommunity/wdpksrc](https://github.com/WDCommunity/wdpksrc)** (BSD 3-Clause, © 2018 WDCommunity). A estrutura do pacote segue o formato e os scripts de exemplo do projeto, em especial o pacote ZeroTier, e a ferramenta `tools/mksapkg-OS5` vem de lá sem modificações. A ideia de baixar o binário oficial na instalação vem do pacote rclone do mesmo projeto. Licença em [`tools/LICENSE-wdpksrc`](tools/LICENSE-wdpksrc).
- **[Tailscale](https://github.com/tailscale/tailscale)** (BSD 3-Clause, © 2020 Tailscale Inc & contributors). É o software de VPN em si, baixado do site oficial na instalação. Licença em [`tools/LICENSE-tailscale`](tools/LICENSE-tailscale).
- **[MrCodeEU/homelab-automation](https://github.com/MrCodeEU/homelab-automation)**, que mostrou que rodar o Tailscale como binário avulso no EX2 Ultra funciona.
- **Certificados raiz** em `tailscale/cacert.pem`: pacote `ca-certificates` do Debian, derivado do repositório de certificados da Mozilla (MPL 2.0).

Desenvolvido com apoio do Claude (Anthropic).

## Licença

BSD 3-Clause. Veja [LICENSE](LICENSE).

## Autor

Jefferson Baptista, [jeffersonbb.com.br](https://jeffersonbb.com.br)
