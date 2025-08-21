# k3s_multi_node

```
cd k3s_multi_node/
sudo bash k3s.sh  #ansible 裝起來有點久
```
裝完執行
```
source ~/.bashrc  
```

修改hosts.ini
```
vi host.ini
```
<img width="867" height="241" alt="截圖 2025-08-21 13 22 09" src="https://github.com/user-attachments/assets/3fbd07a1-9bf1-4104-8024-18da59b0e7c5" />

修改完後執行
```
ansible-playbook -i hosts.ini install_k3s_worker.yml
```
k get po -A 會像下面
<img width="724" height="122" alt="截圖 2025-08-21 13 46 15" src="https://github.com/user-attachments/assets/6b007136-b190-4c16-b1dd-a317e27312d7" />
```
k apply -f pv.yml 
```
```
k apply -f elasticsearch.yml
```
等到elasticsearch 起來
<img width="1055" height="418" alt="截圖 2025-08-21 13 53 44" src="https://github.com/user-attachments/assets/9608d69e-7394-4103-a4b9-9fcd195c42f2" />
```
k get po -A -o wide
```
<img width="993" height="349" alt="截圖 2025-08-21 14 18 19" src="https://github.com/user-attachments/assets/b8955105-ea5a-4017-84df-b22677c8982f" />
```
sudo nano kube-flannel.yml #修改成10.42
k apply -f kube-flannel.yml
```
