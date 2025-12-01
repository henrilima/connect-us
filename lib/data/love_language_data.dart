import 'package:connect/ui/app_color.dart';

class LoveLanguageOption {
  final String text;
  final Map<String, int> scores;

  const LoveLanguageOption({required this.text, required this.scores});
}

class LoveLanguageQuestion {
  final int id;
  final String question;
  final List<LoveLanguageOption> options;

  const LoveLanguageQuestion({
    required this.id,
    required this.question,
    required this.options,
  });
}

final List<LoveLanguageQuestion> loveQuestions = [
  LoveLanguageQuestion(
    id: 1,
    question: 'Depois de um dia cansativo, o que mais te ajudaria a relaxar?',
    options: [
      LoveLanguageOption(
        text: 'Receber um abraço longo e carinhoso',
        scores: {'toque_fisico': 3, 'palavras_de_afirmacao': 1},
      ),
      LoveLanguageOption(
        text: 'Ouvir que sou importante e que vai ficar tudo bem',
        scores: {'palavras_de_afirmacao': 3, 'tempo_de_qualidade': 1},
      ),
      LoveLanguageOption(
        text: 'Ter alguém que prepare o jantar ou resolva algo para mim',
        scores: {'atos_de_servico': 3, 'presentes': 0},
      ),
      LoveLanguageOption(
        text: 'Passar um tempo conversando sobre o dia sem interrupções',
        scores: {'tempo_de_qualidade': 3, 'palavras_de_afirmacao': 1},
      ),
    ],
  ),
  LoveLanguageQuestion(
    id: 2,
    question: 'Como você prefere comemorar uma data especial?',
    options: [
      LoveLanguageOption(
        text: 'Ganhando um presente que tenha significado',
        scores: {'presentes': 3, 'palavras_de_afirmacao': 1},
      ),
      LoveLanguageOption(
        text: 'Com uma viagem ou passeio só nós dois',
        scores: {'tempo_de_qualidade': 3, 'toque_fisico': 1},
      ),
      LoveLanguageOption(
        text: 'Com uma declaração de amor sincera',
        scores: {'palavras_de_afirmacao': 3, 'tempo_de_qualidade': 0},
      ),
      LoveLanguageOption(
        text: 'Com o parceiro organizando tudo para eu não me preocupar',
        scores: {'atos_de_servico': 3, 'presentes': 1},
      ),
    ],
  ),
  LoveLanguageQuestion(
    id: 3,
    question: 'O que mais te magoa em um relacionamento?',
    options: [
      LoveLanguageOption(
        text: 'Críticas duras ou palavras ríspidas',
        scores: {'palavras_de_afirmacao': 3, 'tempo_de_qualidade': 0},
      ),
      LoveLanguageOption(
        text: 'Frieza física ou falta de carinho',
        scores: {'toque_fisico': 3, 'palavras_de_afirmacao': 1},
      ),
      LoveLanguageOption(
        text: 'Sentir que o outro não me escuta ou não tem tempo pra mim',
        scores: {'tempo_de_qualidade': 3, 'atos_de_servico': 0},
      ),
      LoveLanguageOption(
        text: 'Promessas não cumpridas ou falta de ajuda prática',
        scores: {'atos_de_servico': 3, 'palavras_de_afirmacao': 1},
      ),
    ],
  ),
  LoveLanguageQuestion(
    id: 4,
    question: 'Qual gesto espontâneo você mais valoriza?',
    options: [
      LoveLanguageOption(
        text: 'Receber uma mensagem carinhosa no meio do dia',
        scores: {'palavras_de_afirmacao': 3, 'tempo_de_qualidade': 1},
      ),
      LoveLanguageOption(
        text: 'O parceiro trazer meu doce ou comida favorita',
        scores: {'presentes': 3, 'atos_de_servico': 1},
      ),
      LoveLanguageOption(
        text: 'Um beijo ou carinho inesperado',
        scores: {'toque_fisico': 3, 'palavras_de_afirmacao': 0},
      ),
      LoveLanguageOption(
        text: 'Ver que ele(a) arrumou algo que estava bagunçado',
        scores: {'atos_de_servico': 3, 'tempo_de_qualidade': 0},
      ),
    ],
  ),
  LoveLanguageQuestion(
    id: 5,
    question: 'O que faz você se sentir mais amado(a) durante uma conversa?',
    options: [
      LoveLanguageOption(
        text: 'Quando o outro olha nos meus olhos e presta total atenção',
        scores: {'tempo_de_qualidade': 3, 'toque_fisico': 1},
      ),
      LoveLanguageOption(
        text: 'Quando recebo elogios e validação sobre o que digo',
        scores: {'palavras_de_afirmacao': 3, 'tempo_de_qualidade': 1},
      ),
      LoveLanguageOption(
        text: 'Quando há toque físico, como segurar as mãos',
        scores: {'toque_fisico': 3, 'tempo_de_qualidade': 1},
      ),
      LoveLanguageOption(
        text: 'Quando a pessoa oferece ajuda prática para meus problemas',
        scores: {'atos_de_servico': 3, 'palavras_de_afirmacao': 0},
      ),
    ],
  ),
  LoveLanguageQuestion(
    id: 6,
    question: 'Se você fosse planejar o fim de semana perfeito, ele incluiria:',
    options: [
      LoveLanguageOption(
        text: 'Muitos momentos de carinho, abraços e proximidade',
        scores: {'toque_fisico': 3, 'tempo_de_qualidade': 1},
      ),
      LoveLanguageOption(
        text: 'Atividades divertidas feitas juntos, sem pressa',
        scores: {'tempo_de_qualidade': 3, 'palavras_de_afirmacao': 0},
      ),
      LoveLanguageOption(
        text: 'Descansar enquanto o outro cuida das tarefas da casa',
        scores: {'atos_de_servico': 3, 'tempo_de_qualidade': 1},
      ),
      LoveLanguageOption(
        text: 'Trocar presentes ou lembranças especiais',
        scores: {'presentes': 3, 'palavras_de_afirmacao': 1},
      ),
    ],
  ),
  LoveLanguageQuestion(
    id: 7,
    question: 'O que te faz sentir mais seguro(a) na relação?',
    options: [
      LoveLanguageOption(
        text: 'Saber que posso contar com a ajuda prática do outro',
        scores: {'atos_de_servico': 3, 'palavras_de_afirmacao': 1},
      ),
      LoveLanguageOption(
        text: 'Ouvir "eu te amo" e outras afirmações frequentemente',
        scores: {'palavras_de_afirmacao': 3, 'tempo_de_qualidade': 0},
      ),
      LoveLanguageOption(
        text: 'Sentir o toque físico e a presença do outro',
        scores: {'toque_fisico': 3, 'tempo_de_qualidade': 1},
      ),
      LoveLanguageOption(
        text: 'Ter tempo de qualidade consistente juntos',
        scores: {'tempo_de_qualidade': 3, 'palavras_de_afirmacao': 0},
      ),
    ],
  ),
  LoveLanguageQuestion(
    id: 8,
    question: 'Qual destas atitudes te deixaria mais feliz hoje?',
    options: [
      LoveLanguageOption(
        text:
            'Receber um elogio sincero sobre minha aparência ou personalidade',
        scores: {'palavras_de_afirmacao': 3, 'toque_fisico': 0},
      ),
      LoveLanguageOption(
        text: 'Chegar em casa e ver que o jantar está pronto',
        scores: {'atos_de_servico': 3, 'presentes': 1},
      ),
      LoveLanguageOption(
        text: 'Receber um pequeno presente surpresa',
        scores: {'presentes': 3, 'palavras_de_afirmacao': 1},
      ),
      LoveLanguageOption(
        text: 'Ficar de conchinha ou abraçado no sofá',
        scores: {'toque_fisico': 3, 'tempo_de_qualidade': 1},
      ),
    ],
  ),
  LoveLanguageQuestion(
    id: 9,
    question: 'Quando você viaja a trabalho, o que mais sente falta?',
    options: [
      LoveLanguageOption(
        text: 'Das conversas e da companhia do dia a dia',
        scores: {'tempo_de_qualidade': 3, 'palavras_de_afirmacao': 1},
      ),
      LoveLanguageOption(
        text: 'Do contato físico, abraços e beijos',
        scores: {'toque_fisico': 3, 'tempo_de_qualidade': 0},
      ),
      LoveLanguageOption(
        text: 'Da ajuda que o outro me dá nas coisas práticas',
        scores: {'atos_de_servico': 3, 'tempo_de_qualidade': 0},
      ),
      LoveLanguageOption(
        text: 'De ouvir a voz e as palavras de carinho',
        scores: {'palavras_de_afirmacao': 3, 'tempo_de_qualidade': 1},
      ),
    ],
  ),
  LoveLanguageQuestion(
    id: 10,
    question: 'O que significa um presente para você?',
    options: [
      LoveLanguageOption(
        text: 'É uma prova material de que a pessoa pensou em mim',
        scores: {'presentes': 3, 'palavras_de_afirmacao': 1},
      ),
      LoveLanguageOption(
        text: 'Gosto, mas prefiro que gastem tempo comigo',
        scores: {'tempo_de_qualidade': 3, 'presentes': 1},
      ),
      LoveLanguageOption(
        text: 'É bom, mas prefiro ajuda nas tarefas',
        scores: {'atos_de_servico': 3, 'presentes': 0},
      ),
      LoveLanguageOption(
        text: 'Não é tão importante quanto um abraço apertado',
        scores: {'toque_fisico': 3, 'presentes': 0},
      ),
    ],
  ),
  LoveLanguageQuestion(
    id: 11,
    question: 'Como você demonstra amor mais naturalmente?',
    options: [
      LoveLanguageOption(
        text: 'Fazendo coisas úteis para facilitar a vida do outro',
        scores: {'atos_de_servico': 3, 'presentes': 0},
      ),
      LoveLanguageOption(
        text: 'Comprando lembrancinhas e presentes',
        scores: {'presentes': 3, 'atos_de_servico': 1},
      ),
      LoveLanguageOption(
        text: 'Tocando, abraçando e fazendo carinho',
        scores: {'toque_fisico': 3, 'palavras_de_afirmacao': 0},
      ),
      LoveLanguageOption(
        text: 'Elogiando e encorajando verbalmente',
        scores: {'palavras_de_afirmacao': 3, 'tempo_de_qualidade': 0},
      ),
    ],
  ),
  LoveLanguageQuestion(
    id: 12,
    question: 'O que te faz sentir que o outro realmente te entende?',
    options: [
      LoveLanguageOption(
        text: 'Quando ele(a) para tudo para me ouvir de verdade',
        scores: {'tempo_de_qualidade': 3, 'palavras_de_afirmacao': 1},
      ),
      LoveLanguageOption(
        text: 'Quando ele(a) percebe que estou cansado(a) e assume uma tarefa',
        scores: {'atos_de_servico': 3, 'toque_fisico': 0},
      ),
      LoveLanguageOption(
        text: 'Quando me dá algo que tem tudo a ver comigo',
        scores: {'presentes': 3, 'tempo_de_qualidade': 1},
      ),
      LoveLanguageOption(
        text: 'Quando me abraça sem dizer nada e eu me sinto acolhido(a)',
        scores: {'toque_fisico': 3, 'tempo_de_qualidade': 0},
      ),
    ],
  ),
  LoveLanguageQuestion(
    id: 13,
    question: 'Qual a melhor forma de pedir desculpas para você?',
    options: [
      LoveLanguageOption(
        text: 'Mudando o comportamento e ajudando mais',
        scores: {'atos_de_servico': 3, 'palavras_de_afirmacao': 0},
      ),
      LoveLanguageOption(
        text: 'Com um presente ou gesto simbólico de reconciliação',
        scores: {'presentes': 3, 'atos_de_servico': 1},
      ),
      LoveLanguageOption(
        text: 'Escrevendo uma carta ou falando sinceramente',
        scores: {'palavras_de_afirmacao': 3, 'tempo_de_qualidade': 1},
      ),
      LoveLanguageOption(
        text: 'Com aproximação física e carinho para quebrar o gelo',
        scores: {'toque_fisico': 3, 'tempo_de_qualidade': 0},
      ),
    ],
  ),
  LoveLanguageQuestion(
    id: 14,
    question: 'O que você mais admira no seu parceiro(a)?',
    options: [
      LoveLanguageOption(
        text: 'A disposição dele(a) em fazer coisas por mim/nós',
        scores: {'atos_de_servico': 3, 'palavras_de_afirmacao': 1},
      ),
      LoveLanguageOption(
        text: 'A forma carinhosa como ele(a) me toca',
        scores: {'toque_fisico': 3, 'palavras_de_afirmacao': 0},
      ),
      LoveLanguageOption(
        text: 'A capacidade de me ouvir e estar presente',
        scores: {'tempo_de_qualidade': 3, 'palavras_de_afirmacao': 1},
      ),
      LoveLanguageOption(
        text: 'As palavras gentis e motivadoras que ele(a) usa',
        scores: {'palavras_de_afirmacao': 3, 'tempo_de_qualidade': 0},
      ),
    ],
  ),
  LoveLanguageQuestion(
    id: 15,
    question: 'Para você, um relacionamento sem _____ não funciona.',
    options: [
      LoveLanguageOption(
        text: 'Toque físico e intimidade',
        scores: {'toque_fisico': 3, 'tempo_de_qualidade': 0},
      ),
      LoveLanguageOption(
        text: 'Companheirismo e tempo juntos',
        scores: {'tempo_de_qualidade': 3, 'palavras_de_afirmacao': 0},
      ),
      LoveLanguageOption(
        text: 'Apoio prático e parceria nas tarefas',
        scores: {'atos_de_servico': 3, 'tempo_de_qualidade': 1},
      ),
      LoveLanguageOption(
        text: 'Expressões verbais de amor e carinho',
        scores: {'palavras_de_afirmacao': 3, 'toque_fisico': 0},
      ),
    ],
  ),
];

Map<String, Map<String, dynamic>> get loveLanguageDetails => {
  'tempo_de_qualidade': {
    "name": "Tempo de Qualidade",
    "color": AppColors.primaryColorHover,
    "what_is":
        "Para essa pessoa, nada diz 'eu te amo' como atenção total e indivisa. O que importa não é apenas estar na mesma sala (ou na mesma chamada de vídeo), mas estar verdadeiramente presente, conectado e focado no outro, sem distrações.",
    "how_to_show":
        "Dedique momentos exclusivos para vocês. Em relacionamentos à distância, faça videochamadas onde o foco seja apenas conversar, sem mexer no celular. Presencialmente, faça passeios ou simplesmente conversem olhando nos olhos.",
    "practical_examples":
        "Assistir a um filme juntos (mesmo que online), ter uma 'noite do encontro' semanal, fazer uma caminhada sem celulares ou cozinhar juntos enquanto conversam.",
    "needs_when_stressed":
        "Precisa de presença. Quer que você pare o que está fazendo, olhe para ela e escute seus desabafos com empatia e paciência.",
    "to_avoid":
        "Mexer no celular enquanto o outro fala, cancelar compromissos de última hora ou estar fisicamente presente mas mentalmente distante.",
  },
  'palavras_de_afirmacao': {
    "name": "Palavras de Afirmação",
    "color": AppColors.errorColorHover,
    "what_is":
        "Ações não falam mais alto que palavras para essa pessoa. Elogios não solicitados, palavras de encorajamento e declarações de amor são vitais. Insultos podem ser difíceis de esquecer e deixam marcas profundas.",
    "how_to_show":
        "Expresse seus sentimentos verbalmente e por escrito. Mande mensagens de 'bom dia' carinhosas, deixe bilhetes (ou textos longos no WhatsApp) e elogie não só a aparência, mas o caráter e as conquistas.",
    "practical_examples":
        "Dizer 'Tenho muito orgulho de você', enviar uma música que te lembrou dela, escrever uma carta de amor ou simplesmente dizer 'Eu te amo' em momentos aleatórios.",
    "needs_when_stressed":
        "Precisa de validação e segurança. Ouvir 'Vai dar tudo certo', 'Estou com você' ou 'Você é capaz' funciona como um bálsamo emocional.",
    "to_avoid":
        "Críticas não construtivas, sarcasmo ou ignorar o esforço do outro. O silêncio ou a falta de reconhecimento machucam muito.",
  },
  'atos_de_servico': {
    "name": "Atos de Serviço",
    "color": AppColors.secondaryColorHover,
    "what_is":
        "Para essa pessoa, o amor é um verbo. Ela se sente amada quando você faz coisas que aliviam o fardo das responsabilidades dela. 'Deixa que eu faço isso para você' é a frase mais romântica que ela pode ouvir.",
    "how_to_show":
        "Seja proativo. Perceba o que precisa ser feito e faça sem que ela precise pedir. À distância, isso pode ser pedir um jantar para ela num dia cansativo ou ajudar a organizar uma agenda/tarefa online.",
    "practical_examples":
        "Lavar a louça, consertar algo quebrado, ajudar em um trabalho da faculdade/emprego, ou resolver um problema burocrático para ela.",
    "needs_when_stressed":
        "Precisa de ajuda prática. Pergunte 'O que posso fazer para te ajudar agora?' e realmente assuma uma tarefa para diminuir o estresse dela.",
    "to_avoid":
        "Criar mais trabalho para o outro, esquecer promessas de ajuda ou agir como se as tarefas fossem obrigação exclusiva dela.",
  },
  'presentes': {
    "name": "Presentes",
    "color": AppColors.successColorHover,
    "what_is":
        "Não é sobre materialismo, é sobre o pensamento e o esforço por trás do gesto. O presente diz: 'Eu vi isso, lembrei de você e quis te ver sorrir'. É uma representação visual do amor.",
    "how_to_show":
        "Surpreenda em datas não especiais. O valor financeiro não importa. Pode ser uma flor colhida na rua, um chocolate ou um delivery surpresa. Mostre que você conhece os gostos dela.",
    "practical_examples":
        "Trazer a comida favorita dela, dar um livro que ela comentou meses atrás, fazer uma playlist personalizada ou enviar um presente pelo correio/delivery.",
    "needs_when_stressed":
        "Um pequeno mimo pode mudar o dia dela. Receber algo reconfortante (como um doce ou algo relaxante) mostra que você se importa com o bem-estar dela.",
    "to_avoid":
        "Esquecer aniversários ou datas especiais, dar presentes genéricos e sem personalidade, ou criticar o valor dos presentes que recebe.",
  },
  'toque_fisico': {
    "name": "Toque Físico",
    "color": AppColors.infoColor,
    "what_is":
        "Para essa pessoa, a distância física é dolorosa. Ela se sente segura e amada através do contato: mãos dadas, abraços, beijos e carinho. O toque é a âncora emocional dela.",
    "how_to_show":
        "Quando juntos, mantenha o contato físico constante (mãos dadas, abraços demorados). À distância, descreva o carinho que gostaria de fazer, use videochamadas para 'estar perto' e envie itens com seu cheiro.",
    "practical_examples":
        "Fazer cafuné, andar de mãos dadas, abraçar por trás. À distância: enviar um moletom usado, dormir em chamada de vídeo ou descrever detalhadamente um abraço.",
    "needs_when_stressed":
        "Precisa de contenção física. Um abraço apertado e silencioso muitas vezes resolve mais do que mil palavras de conselho.",
    "to_avoid":
        "Rejeitar o toque, ser fisicamente frio ou punir o parceiro com distanciamento físico durante conflitos.",
  },
};
