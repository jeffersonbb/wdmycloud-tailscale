# Guia completo: acesso remoto ao WD My Cloud EX2 Ultra com Tailscale

Este é o passo a passo que eu segui para acessar os arquivos do meu My Cloud de fora de casa, do começo ao fim. Não precisa abrir portas no roteador e funciona mesmo quando a operadora não entrega IP público (CGNAT).

Tempo estimado: 20 minutos.

## Índice

1. [O que você precisa](#1-o-que-você-precisa)
2. [Confira o firmware do My Cloud](#2-confira-o-firmware-do-my-cloud)
3. [Crie a conta no Tailscale](#3-crie-a-conta-no-tailscale)
4. [Instale o app no My Cloud](#4-instale-o-app-no-my-cloud)
5. [Conecte o My Cloud à sua conta](#5-conecte-o-my-cloud-à-sua-conta)
6. [Instale o Tailscale no notebook e no celular](#6-instale-o-tailscale-no-notebook-e-no-celular)
7. [Teste o acesso de fora de casa](#7-teste-o-acesso-de-fora-de-casa)
8. [Mapeie o NAS como unidade de rede](#8-mapeie-o-nas-como-unidade-de-rede)
9. [Recomendações de segurança](#9-recomendações-de-segurança)
10. [Solução de problemas](#10-solução-de-problemas)
11. [Atualizar e desinstalar](#11-atualizar-e-desinstalar)

---

## 1. O que você precisa

- Um **WD My Cloud EX2 Ultra** com **My Cloud OS 5** (firmware 5.x).
- O NAS ligado e com acesso à internet.
- Um computador na mesma rede do NAS para fazer a instalação.
- Uma conta gratuita no Tailscale (passo 3).

## 2. Confira o firmware do My Cloud

1. No computador, abra o painel do My Cloud no navegador, pelo IP do NAS ou por `http://mycloudex2ultra`.
2. Vá em **Configurações → Firmware** (ou veja a tela de informações do dispositivo).
3. A versão precisa começar com **5.** (por exemplo, `5.33.102`).

Se começar com **2.x**, o aparelho ainda está no My Cloud OS 3. Atualize para o OS 5 primeiro, pela página de firmware do painel ou pelo site de suporte da WD. Faça backup antes, porque a atualização não tem volta.

> Dica: se na tela de informações aparecer **"Tipo de conexão: Relay"**, a sua internet provavelmente está atrás de CGNAT. Não tem problema: é justamente esse o caso em que o Tailscale ajuda.

## 3. Crie a conta no Tailscale

1. Acesse [tailscale.com](https://tailscale.com) e clique em **Get started**.
2. Entre com uma conta Google, Microsoft, GitHub ou Apple. O plano pessoal é gratuito.

Use **a mesma conta** em todos os dispositivos (NAS, notebook, celular).

## 4. Instale o app no My Cloud

1. Baixe o pacote: **[MyCloudEX2Ultra_tailscale_1.0.3.bin](https://github.com/jeffersonbb/wdmycloud-tailscale/raw/main/downloads/MyCloudEX2Ultra_tailscale_1.0.3.bin)**.
2. (Opcional) Confira a integridade do arquivo. No PowerShell do Windows:
   ```powershell
   Get-FileHash .\MyCloudEX2Ultra_tailscale_1.0.3.bin -Algorithm SHA256
   ```
   O resultado deve ser igual ao que está em [`downloads/SHA256SUMS`](../downloads/SHA256SUMS).
3. No painel do My Cloud, clique em **Apps**.
4. Clique em **Instalar um aplicativo manualmente** e selecione o arquivo `.bin`.
5. Aguarde a mensagem de instalação concluída. O **Tailscale** aparece na lista de aplicativos instalados.

Na primeira vez, o NAS baixa o Tailscale oficial direto do site da Tailscale e confere o SHA-256. Isso leva de 30 segundos a 1 minuto, dependendo da internet.

## 5. Conecte o My Cloud à sua conta

1. No painel do My Cloud, abra o app **Tailscale** na lista de aplicativos instalados.
2. Clique em **Abrir painel do Tailscale**. Ele abre `http://<ip-do-nas>:5252`.
   - Se o endereço aberto tiver `remotewd.com` e não carregar, digite manualmente `http://<ip-do-nas>:5252`, usando o IP local do NAS (aparece em **Configurações → Rede**).
3. Clique em **Log in** e entre com a sua conta do Tailscale.
4. Confira em [login.tailscale.com/admin/machines](https://login.tailscale.com/admin/machines): o **MyCloudEX2Ultra** deve aparecer como **Connected**.
5. **Anote o IP `100.x.x.x`** do NAS que aparece nessa lista. É ele que você vai usar fora de casa.

> Dica: na mesma página, clique nos três pontinhos ao lado do NAS e escolha **Disable key expiry**. Assim o NAS não é desconectado depois de alguns meses pedindo novo login.

Se o painel da porta 5252 não abrir, veja [Solução de problemas](#10-solução-de-problemas).

## 6. Instale o Tailscale no notebook e no celular

**Windows / macOS**

1. Baixe em [tailscale.com/download](https://tailscale.com/download) e instale.
2. Clique no ícone do Tailscale (perto do relógio no Windows, na barra de menus no macOS) e faça login com a **mesma conta**.
3. O ícone deve indicar **Connected**.

**Android / iPhone**

1. Instale o app **Tailscale** pela Play Store ou App Store.
2. Faça login com a mesma conta e ative a conexão.

## 7. Teste o acesso de fora de casa

Para ter certeza de que funciona na rua, simule a situação:

1. Desconecte o notebook do Wi-Fi de casa.
2. Conecte-o ao **4G do celular** (roteador / hotspot).
3. Confirme que o Tailscale continua **Connected** no notebook.
4. No **Windows Explorer**, digite na barra de endereço:
   ```
   \\100.x.x.x
   ```
   (troque pelo IP do seu NAS) e pressione Enter.
5. Os compartilhamentos do My Cloud aparecem. Se pedir usuário e senha, use os **mesmos do My Cloud**.

No **macOS**: no Finder, **Ir → Conectar ao Servidor** e digite `smb://100.x.x.x`.

No **celular**: use um gerenciador de arquivos com suporte a SMB (por exemplo, o app **Arquivos** do iPhone em "Conectar ao Servidor", ou apps como Solid Explorer / CX File Explorer no Android) apontando para `100.x.x.x`.

## 8. Mapeie o NAS como unidade de rede

Para o NAS aparecer como uma letra de unidade no Windows (como `Z:`):

1. Abra o **Explorador de Arquivos** → **Este Computador**.
2. Clique em **Mapear unidade de rede**.
3. Escolha uma letra e, em **Pasta**, digite `\\100.x.x.x\NomeDoCompartilhamento`.
4. Marque **Reconectar ao entrar**.
5. Se pedir, marque **Conectar usando credenciais diferentes** e informe o usuário e a senha do My Cloud.

Com o Tailscale ligado, a unidade funciona tanto em casa quanto fora.

> Usar o IP `100.x` em vez do IP da rede local faz a mesma unidade funcionar em qualquer lugar, sem precisar trocar o endereço.

## 9. Recomendações de segurança

- **Não abra portas do NAS no roteador.** Com o Tailscale, isso não é necessário.
- **Ative a verificação em duas etapas** na conta usada para entrar no Tailscale (Google, Microsoft etc.). Quem acessar essa conta acessa o seu NAS.
- **Revise os dispositivos** em [login.tailscale.com/admin/machines](https://login.tailscale.com/admin/machines) de vez em quando e remova os que você não usa mais.
- **Desative o SSH** do My Cloud quando não estiver usando.
- **Use senhas fortes** nos usuários do My Cloud.
- O painel do Tailscale (porta 5252) só responde na rede local do NAS.

## 10. Solução de problemas

### Erro "Não é possível fazer upload do pacote de aplicativo" ao instalar

Use a versão mais recente do `.bin` (link no [passo 4](#4-instale-o-app-no-my-cloud)). As versões 1.0.0 e 1.0.1 tinham problemas de compatibilidade corrigidos depois.

### O painel `http://<ip-do-nas>:5252` não abre

1. Aguarde 1 minuto após a instalação ou reinicialização e tente de novo.
2. Use o IP local do NAS, não o endereço com `remotewd.com`.
3. Se continuar sem abrir, veja os logs pelo SSH (abaixo).

### Como acessar o NAS por SSH

1. No painel do My Cloud, vá em **Configurações → Rede** e ative o **SSH**. Ele pede para você definir uma senha.
2. No Windows, abra o **PowerShell** e conecte:
   ```
   ssh sshd@<ip-do-nas>
   ```
3. Para ver os logs:
   ```sh
   cat /tmp/tailscale_apkg.log; echo ---; tail -20 /mnt/HD/HD_a2/.systemfile/tailscale/tailscaled.log; echo ---; tail -20 /mnt/HD/HD_a2/.systemfile/tailscale/tailscale_web.log
   ```

### Fazer login pelo SSH (sem o painel 5252)

```sh
/mnt/HD/HD_a2/Nas_Prog/tailscale/bin/tailscale --socket=/var/run/tailscale/tailscaled.sock up
```

O comando mostra um link. Abra-o no navegador e faça login.

### Ver o status do Tailscale no NAS

```sh
/mnt/HD/HD_a2/Nas_Prog/tailscale/bin/tailscale --socket=/var/run/tailscale/tailscaled.sock status
```

### Mensagens comuns no log

| Mensagem | O que significa | O que fazer |
|---|---|---|
| `sem acesso a pkgs.tailscale.com` | O NAS não conseguiu acessar a internet | Verifique a internet e o DNS do NAS e reinstale |
| `SHA-256 nao confere` | O arquivo baixado veio corrompido ou alterado | Reinstale; se persistir, abra uma issue |
| `No space left on device` | Falta de espaço (versões antigas usavam o `/tmp`) | Atualize para a versão 1.0.3 ou mais nova e rode `rm -rf /tmp/tailscale_dl` |
| `sem binario, abortando` | O download do Tailscale falhou | Veja a mensagem de erro logo acima no log |

### O notebook não acessa `\\100.x.x.x` fora de casa

No PowerShell do notebook:

```powershell
tailscale status
tailscale ping 100.x.x.x
Test-NetConnection 100.x.x.x -Port 445
```

- Se o NAS não aparecer no `tailscale status`, ele não está conectado: veja os logs no NAS.
- Se o `ping` funciona mas a porta 445 não, confira se o compartilhamento de arquivos (SMB) está ativo no My Cloud.
- Algumas redes (Wi-Fi de hotel, redes corporativas) bloqueiam SMB; o Tailscale contorna a maioria desses bloqueios, mas teste também pelo 4G.

## 11. Atualizar e desinstalar

### Atualizar o app

Baixe a versão mais nova do `.bin` e instale por cima pelo painel do My Cloud (**Apps → Instalar um aplicativo manualmente**). O login é mantido.

### Atualizar só o Tailscale

Pelo SSH:

```sh
sh /mnt/HD/HD_a2/Nas_Prog/tailscale/update.sh
```

O script baixa a versão estável mais recente do site da Tailscale e confere o SHA-256.

### Desinstalar

1. Remova o app pelo painel do My Cloud (**Apps** → selecione o Tailscale → **Remover**).
2. Para desvincular o NAS da sua conta de vez, apague o login salvo pelo SSH:
   ```sh
   rm -rf /mnt/HD/HD_a2/.systemfile/tailscale
   ```
3. Remova o dispositivo em [login.tailscale.com/admin/machines](https://login.tailscale.com/admin/machines).

---

Dúvidas ou problemas: abra uma [issue](https://github.com/jeffersonbb/wdmycloud-tailscale/issues) com a versão do firmware e a saída dos logs.

Jefferson Baptista, [jeffersonbb.com.br](https://jeffersonbb.com.br)
