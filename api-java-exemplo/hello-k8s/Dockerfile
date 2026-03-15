# ---------- BUILD STAGE ----------
FROM maven:3.9.6-eclipse-temurin-21 AS builder

WORKDIR /app

# Copia somente pom primeiro (cache dependências)
COPY pom.xml .
RUN --mount=type=cache,id=maven-cache,target=/root/.m2 \
    mvn -B -q -e -DskipTests dependency:go-offline

# Copia código
COPY src ./src

# Build do jar
RUN --mount=type=cache,id=maven-cache,target=/root/.m2 \
    mvn clean package -DskipTests

# Extrai camadas do jar
RUN java -Djarmode=layertools -jar target/hello-k8s-*.jar extract


# ---------- RUNTIME STAGE ----------
FROM eclipse-temurin:21-jre-jammy

WORKDIR /app

# Copia camadas separadamente (melhora cache Docker)
COPY --from=builder app/dependencies/ ./
COPY --from=builder app/spring-boot-loader/ ./
COPY --from=builder app/snapshot-dependencies/ ./
COPY --from=builder app/application/ ./

# JVM otimizada para container
ENV JAVA_TOOL_OPTIONS="-XX:+UseContainerSupport -XX:InitialRAMPercentage=50 -XX:MaxRAMPercentage=75 -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+TieredCompilation -XX:TieredStopAtLevel=1 -XX:+ExitOnOutOfMemoryError"

EXPOSE 8080

ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]