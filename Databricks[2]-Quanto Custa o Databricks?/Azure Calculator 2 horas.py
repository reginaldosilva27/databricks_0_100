# Databricks notebook source
# DBTITLE 1,All Purpose Sem Spot
## DS3 v2 4xvCPU, 14GB RAM, 0.75 per DBU\hora sem SPOT - All Purpose
## Vai variar dependendo do contrato e valor do dolar
vl_dbu_vm_hora = 3.87   
qtd_dias = 1
qtd_horas_dia = 2
total_sem_spot = round((vl_dbu_vm_hora * qtd_horas_dia) * qtd_dias,2) * 2 # Worker + Driver
print("All Purpose: Total VMs + DBUs (2 VMs rodando 12 horas \ dia \ 30 dias (Driver + Worker)): R$" +str(total_sem_spot)) 

# COMMAND ----------

# DBTITLE 1,All Purpose Com Spot
## DS3 v2 4xvCPU, 14GB RAM, 0.75 per DBU\hora COM SPOT - All Purpose
vl_dbu_vm_hora = 3.87
vl_hora_vm_spot = 2.79
qtd_dias = 1
qtd_horas_dia = 2
total_com_spot = round(((vl_dbu_vm_hora * qtd_horas_dia) + (vl_hora_vm_spot * qtd_horas_dia)) * qtd_dias,2)
print("All Purpose: Total VMs + DBUs (2 VMs rodando 12 horas \ dia \ 30 dias (Driver + Worker com SPOT)): R$" +str(total_com_spot)) 

# COMMAND ----------

# DBTITLE 1,Job Cluster Com Spot
## DS3 v2 4xvCPU, 14GB RAM, 0.75 per DBU\hora COM SPOT - Job Cluster
vl_dbu_vm_hora = 2.84
vl_hora_vm_spot = 1.83
qtd_dias = 1
qtd_horas_dia = 2
total_com_spot = round(((vl_dbu_vm_hora * qtd_horas_dia) + (vl_hora_vm_spot * qtd_horas_dia)) * qtd_dias,2)
print("Job Cluster: Total VMs + DBUs (2 VMs rodando 12 horas \ dia \ 30 dias (Driver + Worker com SPOT)): R$" +str(total_com_spot)) 

# COMMAND ----------

# DBTITLE 1,Job Light Com Spot
## DS3 v2 4xvCPU, 14GB RAM, 0.75 per DBU\hora COM SPOT - Job Cluster
vl_dbu_vm_hora = 2.51
vl_hora_vm_spot = 1.53
qtd_dias = 1
qtd_horas_dia = 2
total_com_spot = round(((vl_dbu_vm_hora * qtd_horas_dia) + (vl_hora_vm_spot * qtd_horas_dia)) * qtd_dias,2)
print("Job Ligth: Total VMs + DBUs (2 VMs rodando 12 horas \ dia \ 30 dias (Driver + Worker com SPOT)): R$" +str(total_com_spot)) 

# COMMAND ----------

# DBTITLE 1,Totalizando valor de 2 horas
All Purpose Sem Spot: R$15.48
All Purpose Com Spot: R$13.32
Job Cluster Com Spot: R$9.34
Job Light Com Spot: R$8.08

# COMMAND ----------

## SQL Compute
vl_dbu_hora = 4.48
vl_vm_hora = 5.86 
qtd_dias = 1
qtd_horas_dia = 4
total = round(((vl_dbu_hora * qtd_horas_dia) + (vl_vm_hora * qtd_horas_dia)) * qtd_dias,2)
print("SQL Compute: Total VMs + DBUs (2X-Small (1vm) 12 horas \ dia \ 30 dias): R$" + str(total)) 
