# Compost Collector

<div align="center" style="display: flex; align-items: center; justify-content: center;">

<img src="https://univesp.br/sites/527174b7b24a527adc000002/assets/590b74fa9caf4d3c61001001/Univesp_logo_png_rgb.png" width="250"/>
<img src="https://lh4.googleusercontent.com/dZUO6fz4YHh3TD4DzAy-vqNw46KdnnXny5RriKj4LKn6C_rXdJwFl2PRgYJriZhIn7HWst4SCnIU6mAmo9ep7GdZd_f022xo3o_ewwcei94acA1lBbXNH00aG_GcmoIwlQ=w8188" width="300"/>

</div>

<i>Projeto Integrador I - Plataforma de recolhimento de resíduos e compostagens.</i>

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
