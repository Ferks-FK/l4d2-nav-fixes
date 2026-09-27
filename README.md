# L4D2 Nav Mesh Fixes

Coleção de correções de nav mesh para o Left 4 Dead 2, focadas em pontos específicos de mapas onde os **bots (sobreviventes e infectados) ficam presos sem rota de volta** — geralmente locais que só são reversíveis por jogadores humanos usando técnicas como empurrar um objeto de cenário (ex: uma cadeira) e escalar nele.

Cada fix é um script [VScript](https://developer.valvesoftware.com/wiki/VScript) que cria conexões novas entre áreas do nav mesh em tempo de execução, usando `NavMesh.GetNavAreaByID()` e `area.ConnectTo()`. Nenhuma correção altera o arquivo `.nav` do mapa — tudo é aplicado dinamicamente a cada carregamento de mapa, então nada aqui conflita com o nav mesh original ou com outras modificações.

## Por que isso existe

A IA de navegação do L4D2 é inteiramente baseada no nav mesh: se duas áreas não têm uma conexão registrada, não existe cálculo de rota possível entre elas, não importa a distância. Em vários mapas (oficiais e customizados) existem pontos de "sem volta" intencionais para jogadores humanos, que dependem do motor de física (empurrar/escalar objetos) para contornar — algo que a IA de bot não sabe fazer. O resultado: bots ficam presos indefinidamente nesses pontos.

Esse repositório documenta e corrige esses pontos, mapa por mapa, adicionando manualmente as conexões de nav mesh que faltam.

## Estrutura do repositório

```
l4d2-nav-fixes/
├── scripts/
│   └── vscripts/
│       └── nav_fixes/
│           └── <mapa>_navfixes.nut     # um script por mapa corrigido
└── cfg/
    └── stripper/
        └── maps/
            └── <mapa>.cfg               # injeta o logic_auto que roda o script acima
```

## Instalação (servidor com SourceMod/Metamod + Stripper:Source)

1. Copie o conteúdo de `scripts/vscripts/` para `left4dead2/scripts/vscripts/` do seu servidor.
2. Copie o conteúdo de `cfg/stripper/maps/` para a pasta `maps/` da sua configuração do Stripper:Source (por padrão `addons/stripper/maps/`; se você usa Stripper com múltiplas configs nomeadas, ajuste para `addons/stripper/<sua_config>/maps/`).
3. Reinicie o mapa ou o servidor. O `logic_auto` injetado dispara `RunScriptFile` na entidade `director` ~20 segundos após o spawn do mapa, aplicando as conexões.
4. Confira no console/log do servidor se aparece `[NavFixes] <mapa>_navfixes initialized` seguido de `Fix N applied`.

## Testando localmente (sem SourceMod/Stripper)

Os scripts também rodam via console nativo do jogo, sem precisar de nenhuma extensão:

```
sv_cheats 1
mp_gamemode coop
script_execute nav_fixes/<mapa>_navfixes
```

Como nenhuma correção é salva no `.nav` (não usamos `nav_save`), recarregar o mapa sem rodar o `script_execute` sempre volta ao estado original — útil para comparar o comportamento antes/depois.

## Como adicionar uma correção nova

1. Identifique o ponto onde bots ficam presos.
2. Em teste local, com `sv_cheats 1` e `mp_gamemode coop`, entre em modo de edição do nav mesh:
   ```
   nav_edit 1
   ```
3. Aponte a mira na área "de origem" (o lado de onde os bots vêm, já alcançável) e na(s) área(s) "de destino" (onde os bots ficam presos). Para cada uma:
   ```
   nav_toggle_in_selected_set     " (tecla Z por padrão) — seleciona a área sob a mira
   nav_show_area_info 5           — mostra o ID e atributos da área por 5 segundos
   ```
4. Anote os IDs e a posição (`pos`) de cada área — a diferença de posição entre origem e destino define a direção da conexão (`0`=NORTH, `1`=EAST, `2`=SOUTH, `3`=WEST).
5. Crie `scripts/vscripts/nav_fixes/<mapa>_navfixes.nut` conectando as áreas de destino de volta à área de origem com `.ConnectTo(origem, direção)`.
6. Teste com `script_execute nav_fixes/<mapa>_navfixes` e confirme que um bot consegue voltar.
7. Crie `cfg/stripper/maps/<mapa>.cfg` para automatizar o carregamento em produção.

## Mapas corrigidos

| Mapa | Descrição do ponto | Vídeo antes/depois |
|---|---|---|
| `c1m3_mall` | Corredor do shopping — bots ficavam presos após passar por um ponto sem volta, sem conseguir voltar pro grupo | _pendente_ |

## Limitações conhecidas

- As correções resolvem a **navegação** (o bot passa a considerar a rota e tentar usá-la), mas não necessariamente a **travessia física** de desníveis grandes — dependendo da altura, o bot pode usar o mecanismo padrão do jogo de "teleportar de volta pro grupo" em vez de subir andando. Colocar um objeto físico (ex: uma cadeira) no caminho, como um jogador faria, costuma resolver isso combinado com a correção de nav mesh.
- Fazer o bot agachar/pular automaticamente em pontos específicos exigiria também os atributos `NAV_BASE_CROUCH`/`NAV_BASE_JUMP` (via `left4dhooks`) e um plugin que os torne efetivos (a IA vanilla do L4D2 ignora esses atributos por padrão) — fora do escopo atual deste repositório, que se limita a conexões de nav mesh via VScript.

## Licença

_A definir._
