# HealthLink - Blockchain-based Electronic Health Records (EHR) Management System

HealthLink is a secure, decentralized Electronic Health Records management system built on Hyperledger Fabric blockchain technology. The system provides secure, private, and patient-centered healthcare data management with tamper-proof records and controlled access mechanisms.

## 🏗️ Architecture

The project consists of three main components:

- **Blockchain Network**: Hyperledger Fabric network with 2 organizations (Org1MSP for doctors, Org2MSP for patients)
- **Backend API**: Spring Boot application providing REST APIs for blockchain interaction
- **Frontend**: React.js web application for user interface

## 📋 Prerequisites

### System Requirements
- **Operating System**: Linux (Ubuntu 18.04+ recommended) or macOS
- **Memory**: Minimum 8GB RAM
- **Storage**: At least 20GB free space
- **Docker**: Version 20.10+ and Docker Compose v2+

### Software Dependencies

#### 1. Docker & Docker Compose
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### 2. Hyperledger Fabric Binaries
```bash
# Download Fabric binaries and Docker images
curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.4.0 1.5.0
export PATH=$PWD/fabric-samples/bin:$PATH
```

#### 3. Go Programming Language
```bash
# Download and install Go 1.21+
wget https://golang.org/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz

# Add to ~/.bashrc
echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOROOT/bin' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
source ~/.bashrc
```

#### 4. Node.js & npm
```bash
# Install Node.js 16+ using NodeSource
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version  # Should be v16+
npm --version
```

#### 5. Java Development Kit (JDK 17)
```bash
# Install OpenJDK 17
sudo apt update
sudo apt install openjdk-17-jdk

# Verify installation
java -version
```

#### 6. Maven
```bash
# Install Maven
sudo apt install maven

# Verify installation
mvn -version
```

#### 7. MongoDB
```bash
# Install MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

# Start MongoDB service
sudo systemctl start mongod
sudo systemctl enable mongod
```

## 🚀 Installation & Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd HealthLink
```

### 2. Set up Blockchain Network

#### Step 2.1: Generate Crypto Materials and Artifacts
```bash
cd blockchain/artifacts/channel
chmod +x create-artifacts.sh
./create-artifacts.sh
```
This script will:
- Generate cryptographic materials for organizations and orderers
- Create genesis block for the system channel
- Generate channel configuration transaction for 'mychannel'

#### Step 2.2: Start Hyperledger Fabric Network
```bash
cd ../../../blockchain/artifacts
docker-compose -f docker-compose-persistance.yaml up -d
```
This will start:
- 2 Certificate Authorities (CA) for Org1 and Org2
- 3 Orderer nodes for consensus
- 4 Peer nodes (2 per organization)
- 4 CouchDB instances for state database

**Wait for 30-60 seconds** for all containers to be fully operational.

#### Step 2.3: Create Channel and Deploy Chaincode
```bash
cd ..
chmod +x createChannel.sh deployChaincode.sh ccp-generate.sh

# Create channel 'mychannel' and join all peers
./createChannel.sh

# Package, install, approve, and commit the EHR chaincode
./deployChaincode.sh

# Generate connection profiles for organizations
./ccp-generate.sh
```

**Important**: The deployChaincode.sh script will:
- Package the EHR smart contract from blockchain/chaincode
- Install chaincode on all 4 peers
- Approve chaincode for both organizations
- Commit chaincode definition to the channel
- Initialize the ledger

### 3. Set up Backend (Spring Boot)

#### Step 3.1: Start MongoDB Container
```bash
cd backend
docker-compose up -d
```
This starts MongoDB with:
- Username: admin
- Password: password
- Database: test
- Port: 27017

#### Step 3.2: Build and Run Spring Boot Application
```bash
# Clean and install dependencies
mvn clean install

# Run the application
mvn spring-boot:run
```

The backend will start on `http://localhost:8080` and will:
- Connect to the Hyperledger Fabric network
- Provide REST APIs for EHR operations
- Handle user authentication and authorization
- Manage fabric user registration and enrollment

#### Backend API Endpoints:
- `POST /fabric/login` - User authentication
- `POST /fabric/register` - Register new users
- `POST /fabric/submit` - Submit transactions to blockchain
- `GET /fabric/query` - Query blockchain data

### 4. Set up Frontend (React.js)

```bash
cd frontend

# Install dependencies
npm install

# Start development server
npm run dev
```

The frontend will be available at `http://localhost:5173` (Vite default port).

## 🔧 Configuration

### Environment Variables

#### Backend Configuration
Update backend/src/main/resources/application.properties:

```properties
# MongoDB Configuration
spring.data.mongodb.uri=mongodb://admin:password@localhost:27017/test?authSource=admin

# JWT Configuration
spring.app.jwtSecret=mySecretKey123912738aopsgjnspkmndfsopkvajoirjg94gf2opfng2moknm
spring.app.jwtExpirationMs=3000000

# Session timeout
server.servlet.session.timeout=30m
```

#### Blockchain Network Configuration
Connection profiles are automatically generated in:
- backend/src/main/resources/static/connection-profiles/org1
- backend/src/main/resources/static/connection-profiles/org2

## 👥 User Roles & Organizations

### Organization 1 (Org1MSP) - Healthcare Providers
- **Role**: Doctors and medical staff
- **Capabilities**: Create, update, and access patient records
- **Default Admin**: admin:adminpw

### Organization 2 (Org2MSP) - Patients
- **Role**: Patients and healthcare consumers
- **Capabilities**: View their own records, grant/revoke access permissions
- **Default Admin**: admin:adminpw

## 🔐 Smart Contract Functions

The EHR chaincode (blockchain/chaincode/lib/ehr-contract.js) provides:

- `createEHRRecord(doctorId, patientId, hash, timestamp)` - Create new EHR record
- `updateEHRRecord(doctorId, patientId, newHash, timestamp)` - Update existing record
- `getEHRRecord(patientId, doctorId)` - Retrieve specific record
- `getAllEHRRecordByPatient(patientId)` - Get all records for a patient
- `getAllEHRRecordByDoctor(doctorId)` - Get all records by a doctor
- `recordAccess(doctorId, patientId, hash, timestamp)` - Log access attempt
- `activateAccess(doctorId, patientId, hash, timestamp)` - Grant access
- `revokeAccess(doctorId, patientId, hash, timestamp)` - Revoke access
- `getAccessHistory(patientId, doctorId)` - View access audit trail

## 🧪 Testing

### Test the Blockchain Network
```bash
cd blockchain

# Test chaincode functionality
./testAPIs.sh

# Check peer logs
docker logs peer0.org1.example.com

# Check orderer logs
docker logs orderer.example.com
```

### Test Backend APIs
```bash
# Login as admin
curl -X POST http://localhost:8080/fabric/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"adminpw","mspId":"Org1MSP"}'

# Register new user (requires JWT token)
curl -X POST http://localhost:8080/fabric/register \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -F "username=doctor1" \
  -F "password=doctorpass"
```

## 🛠️ Troubleshooting

### Common Issues

#### 1. Docker Permission Denied
```bash
sudo usermod -aG docker $USER
# Logout and login again
```

#### 2. Port Already in Use
```bash
# Check running containers
docker ps

# Stop all containers
docker-compose down

# Remove all containers and volumes
docker-compose down -v
```

#### 3. Chaincode Installation Failed
```bash
# Clean up and retry
cd blockchain
docker-compose down -v
rm -rf channel-artifacts/*
rm ehr.tar.gz
./createChannel.sh
./deployChaincode.sh
```

#### 4. MongoDB Connection Issues
```bash
# Check MongoDB status
sudo systemctl status mongod

# Restart MongoDB
sudo systemctl restart mongod
```

#### 5. Clear Fabric Network Data
```bash
# Remove all Docker volumes for fresh start
docker volume prune
sudo rm -rf /var/ehr/*
```

## 📝 Development Notes

- The blockchain network uses **CouchDB** as the state database for rich queries
- **TLS** is enabled for all peer-to-peer communication
- The system supports **multi-organization** architecture with separate MSPs
- **JWT tokens** are used for API authentication
- **Composite keys** are used in chaincode for efficient data retrieval

## 🔒 Security Features

- **Blockchain immutability** for audit trails
- **MSP-based identity** management
- **TLS encryption** for all communications
- **Access control** through smart contracts
- **JWT-based** API authentication

## 📚 Additional Resources

- [Hyperledger Fabric Documentation](https://hyperledger-fabric.readthedocs.io/)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [React.js Documentation](https://reactjs.org/docs)
- [MongoDB Documentation](https://docs.mongodb.com/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the Apache 2.0 License - see the LICENSE file for details.

---

**Note**: This system is for educational and development purposes. For production deployment, additional security measures, monitoring, and compliance configurations are required.