-- Deploy votolegal:0031-issue-priorities-fix to pg
-- requires: 0030-new-issue-priorities

BEGIN;

TRUNCATE candidate_issue_priority, issue_priority RESTART IDENTITY ;

INSERT INTO issue_priority (name) VALUES ('Acessibilidade'), ('Acesso à internet'), ('Agricultura urbana'), ('Agropecuária'), ('Alimentação saudável'), ('Apoio às pequenas e medias empresas'), ('Compras públicas sustentáveis'), ('Construção sustentável'), ('Cultura'), ('Cultura de paz'), ('Democracia direta'), ('Democracia participativa'), ('Direitos dos animais'), ('Economia criativa'), ('Educação'), ('Eficiência energética'), ('Energias renováveis'), ('Espaços verdes e biodiversidade'), ('Esporte'), ('Esporte educacional'), ('Esporte educacional'), ('Formação profissional'), ('Gestão da água'), ('Gestão de resíduos e reciclagem inclusiva'), ('Gestão integrada e eficiente'), ('Gestão participativa'), ('Governança metropolitana'), ('Habitação'), ('Igualdade entre os gêneros'), ('Igualdade entre raças e etnias'), ('Inclusão digital'), ('Inclusão social'), ('Meio ambiente'), ('Monitoramento e prestação de contas'), ('Mudanças climáticas'), ('Oportunidades de emprego'), ('Planejamento e desenho urbano'), ('Programas contra pobreza'), ('Qualidade do ar'), ('Qualidade dos serviços públicos'), ('Respeito à diversidade sexual'), ('Saúde'), ('Segurança'), ('Transparência e dados abertos'), ('Transporte individual motorizado'), ('Transporte público'), ('Transportes ativos (pedestres e ciclistas)'), ('Veículos menos poluentes') ;

COMMIT;
