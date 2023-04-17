# Garbage Collector

<div align="center">
<img src="https://univesp.br/sites/527174b7b24a527adc000002/assets/590b74fa9caf4d3c61001001/Univesp_logo_png_rgb.png" width="300">

<i>Projeto Integrador I - Plataforma de recolhimento de resíduos e compostagens.</i>

</div>

O projeto foi construído utilizando o framework web *Shiny*, escrito na linguagem de programação **R**. Para o armazenamento de dados, utilizamos um banco de dados relacional *PostgreSQL*.

## Dependências

A aplicação contém um arquivo *docker-compose* para facilitar o uso de dependências. Para rodar a aplicação juntamente com o banco de dados, utilize o comando abaixo:

```bash
docker-compose up -d
```

Caso prefire *buildar* somente o dashboard, utilize o comando abaixo:

```bash
docker build -t compost-collector . --build-arg ARG_GIS_USER="postgres" --build-arg=ARG_GIS_PWD="postgres"
```
