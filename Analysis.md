# 1.Introduction
1) Summary
우리는 하루를 마치며 오늘의 사건과 감정을 기록하고 싶어 하지만, 단순한 텍스트 위주의 일기는 지속하기가 어렵고 금방 지루함을 느끼곤 한다.
반면, 현대인들은 정서적 교감을 위해 반려동물을 키우고 싶어 하지만 현실적인 제약으로 인해 포기하는 경우가 많다.
이러한 두 가지 문제를 동시에 해결하기 위해 고안한 시스템이 바로 ‘LOG-PET’이다.
본 시스템은 사용자가 반려동물을 돌보는 행위 자체가 하나의 일기가 되도록 설계되었다.
사용자가 오늘 있었던 일을 동물에게 들려주거나 기록하면 시스템은 이를 단순한 저장에 그치지 않고 동물의 상태 수치와 대화에 반영한다.
즉, 사용자는 반려동물을 키우기 위해 자연스럽게 하루를 기록하게 되고 동물은 그 기록을 바탕으로 사용자에게 반응하며 정서적 위안을 제공한다. 
결과적으로 본 소프트웨어는 단순한 육성 게임을 넘어 사용자의 일상이 기록된 소중한 성장 다이어리의 역할을 수행하고자 한다.
2) Description of Project Features
2-1.일기 기반의 상호작용:사용자가 오늘의 주요 사건이나 감정을 입력하면 시스템은 이를 ‘로그’로 저장함과 동시에 동물의 호감도를 상승시킨다.
                        단순히 버튼을 누르는 육성이 아니라 사용자의 실제 일상을 동물과 공유함으로써 기록의 동기를 부여하고 정서적 유대를 강화한다.
2-2.텍스트 분석을 통한 감정 피드백: 사용자가 작성한 일기 내용 중 특정 키워드나 감정을 시스템이 파악하여 동물의 반응을 결정한다. 
                                 예를 들어 사용자가 우울한 내용을 기록하면 동물이 위로의 말풍선을 출력하거나 기쁜 내용을 기록하면 함께 즐거워하는 말풍선을 출력하여 
                                 실시간 교감의 깊이를 높인다.
2-3.추억의 재회 시스템: 동물이 독립한 이후에도 사용자가 작성했던 과거의 일기 내용들은 World Server에 영구 보관된다. 
                       사용자가 떠나보낸 아이를 다시 불러오면 동물은 과거 일기장의 특정 날짜 기록을 언급하며 
                       "그날은 이런 일이 있었죠?"와 같은 대사를 건네어 사용자가 자신의 과거를 회상할 수 있는 통로 역할을 한다.
2-4.시간 동기화 및 데이터 관리: 실제 시간의 흐름에 따라 일기 작성 주기를 관리하며 외부 서버 연동을 통해 하루에 한 번 정해진 시간에 기록을 유도한다. 
                              모든 기록은 사용자의 계정별로 Storage DB에 안전하게 관리되어 기기를 변경하더라도 소중한 일상 기록과 동물의 성장 데이터가 유지되도록 한다.
# 2.Use case analysis
1)
```mermaid
graph LR
    classDef actor fill:#ffffff,stroke:#000000,stroke-width:2px;
    classDef system fill:#f9f9f9,stroke:#000000,stroke-width:2px;
    classDef logic fill:#ffffff,stroke:#333333,stroke-dasharray: 5 5;


    Owner(((Owner))):::actor
    DB[(Storage DB)]:::system
    TimeServer[Time Server]:::system
    WorldServer[World Server]:::system

    subgraph LOG_PET_System [LOG-PET]

        UC1(회원가입)
        UC2(로그인)
        UC3(반려동물 등록)


        UC4(데이터 동기화)
        UC5(상태 조회)


        UC6(육성 관리)
        UC10(일기 작성 및 교감)
        UC7(성장 처리)


        UC8(동물 세상 독립)
        UC9(추억 기록 출력)
    end

    %% User Interaction
    Owner --- UC1
    Owner --- UC2
    Owner --- UC3
    Owner --- UC5
    Owner --- UC6
    Owner --- UC8
    Owner --- UC9
    Owner --- UC10


    UC1 --- DB
    UC2 --- DB
    UC3 --- DB
    
    UC2 -.->|include| UC4
    UC4 --- TimeServer
    UC4 --- DB
    UC5 --- DB
    UC6 --- DB
    UC10 --- DB

    UC6 -.->|extend| UC7
    UC7 --- DB

    UC8 --- DB
    UC8 --- WorldServer
    UC9 --- WorldServer
```
2)
Use Case #1: 회원가입
Summary	- 사용자가 ‘LOG-PET’을 처음 이용하고자 할 때, 고유 계정을 생성하여 개인화된 육성 환경을 구축한다.
Scope -	LOG-PET (반려동물 성장 및 독립 시뮬레이션 시스템)
Level -	User Level
Author	
Last Update	- 2026-05-08
Status	- Analysis
Primary Actor	- Owner
Preconditions- 1. 시스템(App)이 정상적으로 실행되어야 한다.
               2. 가상 서버(Virtual Server) 및 Storage DB 모듈이 활성화되어야 한다.
Trigger	- 메인 초기 화면에서 [회원가입] 버튼을 선택한다.
Success Post Condition	- 입력한 정보가 Storage DB에 텍스트 파일 형태로 영구 저장되며 회원가입 성공 메시지가 출력된다.
Failed Post Condition	- 계정 생성이 취소되며 오류 메시지와 함께 회원가입 양식 입력 화면이 유지된다.

Step-Action
S. 사용자가 시스템에 새로운 계정을 등록한다.
1. 사용자는 LOG-PET 어플리케이션을 실행한다.
2. 사용자는 초기 화면 메뉴 중 [회원가입]을 선택한다.
3. 시스템은 아이디, 비밀번호, 비밀번호 확인 입력을 위한 양식(Form)을 화면에 출력한다.
4. 사용자는 각 항목에 정보를 기입하고 [등록] 버튼을 누른다.
5. 시스템은 Storage DB 역할을 하는 내부 클래스에 데이터 검증을 요청한다.
6. 시스템은 기존 저장된 텍스트 파일 내역을 전수 조사하여 아이디 중복 여부를 확인한다.
7. 중복이 없고 양식이 올바를 경우, 새로운 사용자 객체를 생성하여 DB 파일에 기록한다.
8. 회원가입 완료 메시지를 띄우고 다시 로그인 화면으로 이동하며 종료한다.

Step-Branching Action
4 -4a. 필수 입력 항목(아이디 또는 비밀번호)을 누락한 경우
   4a.1. 시스템은 "모든 정보를 입력해야 합니다"라는 경고 메시지를 출력한다.
   4a.2. 입력 중이던 회원 정보 화면을 유지한다.
4- 4b. 비밀번호와 비밀번호 확인 입력값이 일치하지 않는 경우
   4b.1. 시스템은 "비밀번호가 일치하지 않습니다"라는 메시지를 출력한다.
   4b.2. 비밀번호 입력란을 초기화하고 재입력을 유도한다.
6- 6a. 이미 등록된 아이디로 가입을 시도하는 경우
   6a.1. 시스템은 "이미 존재하는 아이디입니다"라는 중복 에러 메시지를 출력한다.
   6a.2. 아이디 입력란으로 커서를 이동시켜 수정을 유도한다.
7- 7a. Storage DB(파일 시스템) 쓰기 오류가 발생한 경우
   7a.1. 시스템은 "저장 공간 부족 혹은 시스템 오류로 가입에 실패했습니다"를 알린다.
   7a.2. 비정상 종료를 방지하기 위해 예외 처리를 수행하고 초기 화면으로 돌아간다.
   
RELATED INFORMATION
FIELD-VALUE
Performance: 사용자 등록 정보가 파일에 쓰여지고 응답하는 시간은 3초 미만이어야 함.
Frequency: 신규 사용자 유입 시 발생 (최초 1회)Concurrency단일 기기 기반의 가상 서버 환경이므로 동시성 이슈는 고려하지 않음.
Due Date: 

Use Case #2. 로그인
Summary - 사용자가 등록된 계정 정보를 입력하여 인증을 받고 기존의 육성 환경과 반려동물 데이터를 복구한다.
Scope - LOG-PETLevelUser 
Level - 
Status - Analysis
Primary Actor - Owner
Preconditions - 1. 시스템이 실행 중이어야 한다.
                2. Storage DB에 최소 하나 이상의 사용자 계정 데이터가 존재해야 한다.
Trigger - 초기 화면에서 로그인 정보를 입력하고 [로그인] 버튼을 선택한다.
Success Post Condition - 메인 엔진이 구동되며 데이터 동기화가 자동으로 연쇄 실행된다.
Failed Post Condition - 인증 실패 메시지를 출력하며 시스템 접근 권한이 제한된다.

Step-Action
S.	사용자가 시스템 인증을 통해 기존 데이터를 불러온다.
1.	사용자는 자신의 아이디와 비밀번호를 입력하고 로그인을 요청한다.
2.	시스템은 Storage DB 파일에서 해당 아이디와 일치하는 레코드를 검색한다.
3.	시스템은 입력된 비밀번호가 저장된 데이터와 일치하는지 대조한다.
4.	일치할 경우, 시스템은 해당 사용자의 반려동물 인스턴스 정보를 메모리에 로드한다.
5.	시스템은 메인 화면을 활성화하고 동기화(UC-4) 로직을 호출하며 종료한다.

Step - Branching Action
3- 3a. 아이디가 존재하지 않거나 비밀번호가 틀린 경우
   3a.1. 시스템은 "계정 정보가 올바르지 않습니다" 메시지를 출력한다.
   3a.2. 로그인 입력 화면으로 돌아온다.

Use Case #3. 반려동물 등록
Summary - 로그인을 완료한 사용자가 시스템 내에서 육성할 고유의 반려동물 객체를 생성하고 초기화한다.
Scope - LOG-PET
Level - User Level
Author - 
Last Update - 2026-05-08
Status - Analysis
Primary Actor - Owner
Preconditions - 1. 사용자가 성공적으로 로그인한 상태여야 한다.
                2. 해당 계정에 활성화된 반려동물 데이터가 존재하지 않아야 한다.
Trigger - 로그인 후 반려동물이 없을 경우 나타나는 새 친구 만들기 화면에서 정보를 입력한다.
Success Post Condition - 새로운 반려동물 인스턴스가 생성되어 사용자의 계정에 귀속되고 Storage DB에 텍스트 파일 형식으로 저장된다.
Failed Post Condition - 반려동물 객체가 생성되지 않으며 입력을 완료할 때까지 메인 육성 화면으로 진입이 제한된다.

Step-Action
S. 사용자가 육성할 새로운 디지털 반려동물을 시스템에 등록한다.
1. 시스템은 반려동물의 종 리스트와 이름 입력창을 화면에 제공한다.
2. 사용자는 제공된 리스트에서 원하는 종을 선택한다.
3. 사용자는 반려동물에게 부여할 고유한 이름을 텍스트로 입력한다.
4. 사용자가 [등록 완료] 버튼을 누른다.
5. 시스템은 선택된 종에 해당하는 기본 스탯(허기 100, 청결 100 등)과 외형 클래스를 할당한다.
6. 시스템은 생성된 반려동물 객체 데이터를 Storage DB에 새로운 파일 레코드로 기록한다.
7. 등록 성공 메시지와 함께 반려동물의 초기 상태가 표시되는 메인 육성 화면으로 이동한다.

Step - Branching Action
3 - 3a. 이름을 입력하지 않고 등록을 시도하는 경우
    3a.1. 시스템은 "반려동물의 이름을 입력해주세요"라는 경고 메시지를 출력한다.
    3a.2. 이름 입력란으로 포커스를 이동시킨다.
3 - 3b. 이름에 특수문자나 부적절한 단어가 포함된 경우
    3b.1. 시스템은 "사용할 수 없는 이름 형식입니다" 메시지를 출력한다.
    3b.2. 이름 재입력을 요구한다.
6 - 6a. 데이터베이스 쓰기 오류로 파일 저장이 실패한 경우
    6a.1. 시스템은 "데이터 저장에 실패했습니다. 다시 시도해주세요" 메시지를 알린다.
    6a.2. 등록 초기 단계로 돌아가거나 재시도 버튼을 활성화한다.
    
RELATED INFORMATION
FIELD-VALUE
Performance: 종 선택 및 이름 입력 후 객체 생성 처리는 1초 이내에 완료되어야 함.
Frequency: 계정당 최초 1회 (혹은 기존 동물의 독립/졸업 후 새 등록 시)
Concurrency: 없음
Due Date: 

Use Case #4. 데이터 동기
Summary- 사용자가 시스템에 접속하지 않은 시간 동안의 실제 경과 시간을 계산하여 반려동물의 상태 수치를 물리적으로 자동 반영한다.
Scope -	LOG-PET
Level -	User Level
Author -
Last Update -	2026-05-08
Status -	Analysis
Primary Actor -	Owner, Time Server
Preconditions	- 1. 사용자가 로그인에 성공하여 시스템 메인 엔진이 구동되어야 한다.
                2. Storage DB에서 마지막 접속 시점의 Timestamp 데이터가 로드되어야 한다.
Trigger -	로그인이 완료된 직후 시스템에 의해 자동으로 실행된다.
Success Post Condition - 부재 시간만큼 차감된 스탯이 UI 게이지에 즉각 반영되며 Storage DB 내의 데이터가 최신화된다.
Failed Post Condition	- 시간 동기화에 실패할 경우, 마지막 저장된 상태가 유지되거나 오류 메시지가 출력된다.

Step-Action
S.	현실의 흐름과 동기화하여 반려동물의 상태를 실시간으로 갱신한다.
1. 시스템은 로그인 완료 직후 외부 표준 시간 API(Time Server)에 현재 시간 정보를 요청한다.
2.	시스템은 Storage DB의 파일에서 마지막으로 기록된 동물의 상태 정보와 Timestamp를 호출한다.
3.	시스템은 [현재 시간 - 마지막 접속 시간]을 계산하여 초/분 단위의 경과 시간을 산출한다.
4. 산출된 시간을 기반으로 반려동물의 배고픔, 청결도 등 감소 스탯을 연산한다. (예: 1시간당 -10)
5.	연산된 결과값이 현재 스탯에서 차감되어 UI 게이지에 실시간으로 업데이트된다.
6. 갱신된 시간과 상태 데이터가 Storage DB에 기록되며 종료된다.

Step-Branching Action
1- 1a. 네트워크 환경 불안정으로 Time Server 연결에 실패한 경우
   1a.1. 시스템은 기기의 로컬 시스템 시간을 대조 시간으로 임시 채택한다.
   1a.2. 상단 바에 "오프라인 모드: 시간 동기화가 부정확할 수 있습니다" 알림을 표시한다.
3- 3a. 사용자가 기기 시간을 임의로 수정하여 과거 시간으로 조작한 경우
   3a.1. 시스템은 [현재 시간 < 마지막 접속 시간]인 비정상 상황을 감지한다.
   3a.2. "시간 정보가 올바르지 않습니다" 메시지를 출력하고 스탯 차감을 수행하지 않는다.
5- 5a. 스탯 차감 결과가 최소치(0) 이하로 떨어지는 경우
   5a.1. 수치를 0으로 고정하고, 동물 객체의 상태를 배고픔 혹은 더러움 상태로 전환한다.

RELATED INFORMATION
FIELD-VALUE
Performance:시간 API 호출 및 연산 처리는 사용자 대기 시간을 최소화하기 위해 2초 이내에 완료되어야 함.
Frequency:앱 실행 시 로그인 직후 매번 발생.
Concurrency:단일 기기 환경이므로 고려하지 않음.
Due Date: 

Use Case #5 : 상태확인
Summary - 사용자가 현재 반려동물의 욕구 상태를 실시간으로 확인하여 즉각적인 육성 관리를 판단할 수 있도록 돕는다.
Scope - LOG-PET
Level - User Level
Author - 
Last Update - 2026-05-08
Status - Analysis
Primary Actor - Owner
Preconditions - 1. 사용자가 로그인한 상태여야 한다.
                2. 반려동물이 등록되어 객체가 활성화된 상태여야 한다.
Trigger - 메인 화면의 상태 바를 확인하거나 상세 정보 메뉴를 선택한다.
Success Post Condition - 동물의 현재 스탯 수치가 시각적인 게이지 또는 테이블 형태로 정확히 출력된다.
Failed Post Condition - 데이터 로드 실패 시 수치가 표시되지 않거나 기본값(0)으로 표시된다.
Step-Action
S. 사용자가 반려동물의 현재 욕구와 친밀도 수치를 실시간으로 모니터링한다.
1. 시스템은 앱 구동 중 Storage DB에서 실시간으로 변동되는 스탯 데이터를 지속적으로 읽어온다.
2. 시스템은 읽어온 수치를 직관적인 게이지 UI로 변환한다.
3. 사용자는 화면 상단 또는 상세 정보 탭을 통해 동물의 현재 필요 사항을 파악한다.
4. 수치가 일정 수준 이하로 떨어질 경우, 시스템은 시각적 강조(빨간색 게이지 등)를 통해 사용자에게 알린다.
5. 사용자가 정보를 확인한 후 육성 액션(UC-6)을 결정하며 종료된다.

Step-Branching Action
1- 1a. Storage DB 파일에서 데이터를 읽어오는 과정에서 오류가 발생한 경우
   1a.1. 시스템은 "상태 데이터를 불러올 수 없습니다" 메시지를 출력한다.
   1a.2. 마지막으로 메모리에 캐싱된 수치를 임시로 보여준다.
4- 4a. 스탯 수치에 따라 동물의 외형 애니메이션이 변해야 하는 경우
   4a.1. 시스템은 수치 범위를 체크하여 '배고픈 표정' 또는 '졸린 표정' 리소스를 호출한다.
   4a.2. 상태 UI 옆에 동물의 감정 아이콘을 함께 표시한다.
   
RELATED INFORMATION
FIELD-VALUE
Performance: 스탯 변화가 UI에 반영되는 속도는 실시간이어야 하며 지연 시간은 0.5초 이내여야 함.
Frequency: 앱 사용 중 지속적으로 발생.
Concurrency: 없음.
Due Date: 

Use Case #6 : 육성관리
Summary - 주인이 먹이 주기, 산책, 씻기기 등의 명령을 실행하여 반려동물의 욕구를 충족시키고 상태 수치를 직접적으로 변화시킨다.
Scope - LOG-PET
Level - User Level
Author- 
Last Update - 2026-05-08
Status - Analysis
Primary Actor - Owner
Preconditions - 1. 사용자가 로그인 상태여야 한다.
                2. 반려동물이 등록되어 메인 육성 화면이 활성화되어야 한다.
Trigger - 메인 화면의 상호작용 아이콘 중 하나를 클릭한다.
Success Post Condition - 선택한 액션에 따라 해당 스탯이 즉각 상승하며 활동 내역이 Storage DB에 로그로 기록된다.
Failed Post Condition - 조건 미달 시 액션이 취소되고 기존 스탯이 유지된다.
Step-Action
S.사용자가 능동적으로 반려동물을 돌보아 상태를 개선시킨다.
1. 사용자가 반려동물의 상태를 확인한 후 필요한 상호작용 버튼을 선택한다.
2. 시스템은 선택된 액션에 해당하는 스탯 증가 가중치를 계산한다.
3. 시스템은 실시간으로 동물의 수치를 업데이트한다. 
4. 시스템은 해당 상호작용의 수행 기록)을 활동 로그로 생성한다.
5. 생성된 로그와 변경된 스탯 데이터를 Storage DB 파일에 실시간으로 저장한다.
6. 화면에 동물이 기뻐하는 애니메이션과 텍스트 피드백을 출력하며 종료한다.

Step-Branching Action
2- 2a. 특정 스탯이 이미 최대치(100)인 상태에서 액션을 시도하는 경우
   2a.1. 시스템은 수치를 더 이상 올리지 않고 "이미 충분해요!"라는 메시지를 출력한다.
   2a.2. 액션 애니메이션은 수행하되, 실질적인 데이터 변경은 최소화한다.
5- 5a. 상호작용 도중 시스템이 비정상적으로 종료된 경우
   5a.1. 시스템은 신뢰성 원칙에 따라 종료 직전까지의 로그를 파일로 백업한다.
   5a.2. 재접속 시 마지막으로 성공한 저장 지점부터 데이터를 복구한다.
   
RELATED INFORMATION
FIELD-VALUE
Performance: 버튼 클릭 후 UI 반영 및 데이터 저장까지의 시간은 1초 이내여야 함.
Frequency:사용자의 필요에 따라 수시로 발생.
Concurrency:없음.
Due Date: 

Use Case #7 : 성장 처리
Summary - 반려동물이 특정 경험치와 성장 시간을 충족하면 시스템이 자동으로 외형 클래스를 변경하고 신체 발달 단계(아기→성체)를 전이시킨다.
Scope - LOG-PET
Level - User Level
Author - 
Last Update - 2026-05-08
Status - Analysis
Primary Actor - System
Preconditions - 1. 반려동물 객체가 활성화되어 있어야 한다.
                2. 육성 관리 또는 일기 작성을 통해 누적된 경험치가 레벨업 기준치에 도달해야 한다.
Trigger - 스탯 업데이트 시 시스템 엔진에 의해 성장 조건 충족 여부가 자동으로 체크된다.
Success Post Condition - 반려동물의 외형이 성체로 교체되고 성장 단계에 따른 스탯 소모 가중치가 새롭게 적용되어 Storage DB에 저장된다.
Failed Post Condition - 조건 미충족 시 현재 성장 단계를 유지하며 데이터 업데이트 오류 시 이전 단계의 데이터를 복구한다.

Step-Action
S. 시스템이 반려동물의 성장 조건을 감지하여 단계를 진화시킨다.
1. 시스템 엔진은 실시간으로 반려동물의 누적 경험치와 등록 후 경과 시간을 모니터링한다.
2. 설정된 성장 임계값에 도달하면 성장 로직을 실행한다.
3. 시스템은 객체 지향 설계의 다형성을 활용하여 현재 '아기(Baby)' 클래스를 '성체(Adult)' 클래스로 교체한다.
4. 성체 단계에 맞는 새로운 리소스(이미지, 애니메이션)와 스탯 소모 가중치를 데이터에 매핑한다.
5. 시스템은 성장 완료 메시지와 함께 화면에 화려한 진화 연출(효과음, 이펙트)을 제공한다.
6. 업데이트된 성장 단계 정보를 Storage DB의 파일 내역에 영구 기록한다.

Step-Branching Action
3- 3a. 성장 단계 전이 중 리소스 로딩 오류가 발생한 경우
   3a.1. 시스템은 비정상 종료를 방지하기 위해 기본 성체 리소스를 할당한다.
   3a.2. 오류 로그를 기록하고 다음 접속 시 리소스 재검증을 수행한다.
6- 6a. 성장 데이터 저장 중 파일 시스템 에러가 발생한 경우
   6a.1. 시스템은 '신뢰성(NFS)' 원칙에 따라 트랜잭션을 롤백하여 성장 전 데이터를 유지한다.
   6a.2. 사용자에게 "성장 데이터 기록 실패"를 알리고 재시도를 유도한다.

RELATED INFORMATION
FIELD-VALUE
Performance: 외형 클래스 교체 및 화면 전환 연출은 끊김 없이 3초 이내에 완료되어야 함.
Frequency: 각 성장 단계 도달 시 1회 발생.
Concurrency: 시스템 엔진에 의한 단일 프로세스로 처리됨.
Due Date:

Use Case #8 : 동물 세상 독립
Summary - 모든 성장 단계를 마친 반려동물을 시스템 관리 영역에서 해방시키고 그동안의 모든 데이터를 외부 서버로 이전하여 ‘영구 추억’ 상태로 보존한다.
Scope - LOG-PET
Level - User Level
Author -
Last Update - 2026-05-08
Status - Analysis
Primary Actor - Owner, World Server
Preconditions - 1. 반려동물이 최종 성장 단계에 도달해야 한다.
                2. 특정 육성 기간 또는 목표 경험치를 완전히 충족해야 한다.
Trigger - 최종 성장 후 활성화되는 [독립 시키기] 또는 [동물 세상으로 보내기] 버튼을 선택한다.
Success Post Condition - 데이터가 World Server로 아카이빙되며 Storage DB 내의 활성 반려동물 인스턴스는 제거된다.
Failed Post Condition - 서버 전송 실패 시 독립 처리가 취소되며 동물의 데이터는 로컬 Storage DB에 그대로 유지된다.

Step-Action
S. 반려동물을 동물 세상으로 보내어 육성 여정을 아름답게 마무리한다.
1. 사용자는 최종 성장을 마친 반려동물에게 독립 승인 명령을 내린다.
2. 시스템은 해당 반려동물의 기본 정보, 최종 스탯, 그리고 누적된 모든 Activity Log를 패키징한다.
3. 시스템은 패키징된 데이터를 가상 World Server로 전송한다.
4. World Server는 데이터를 수신하여 '영구 기억 저장소'에 아카이빙하고 성공 신호를 보낸다.
5. 시스템은 Storage DB에서 현재 활성화된 동물의 데이터를 삭제(혹은 읽기 전용으로 변경)하여 졸업 처리한다.
6. 사용자에게 이별 및 독립을 기념하는 엔딩 연출(편지, 회상 영상 등)을 제공하며 종료한다.
   
Step-Branching Action
3- 3a. World Server와의 연결이 끊겨 데이터 전송이 불가능한 경우
   3a.1. 시스템은 "서버 연결이 원활하지 않아 독립이 지연됩니다" 메시지를 출력한다.
   3a.2. 독립 처리를 중단하고, 네트워크가 복구될 때까지 로컬에 데이터를 보존한다.
5- 5a. 로컬 데이터 삭제/변경 중 오류가 발생한 경우
   5a.1. 데이터 정합성을 위해 서버로 전송된 데이터를 무효화하거나 재시도 로직을 가동한다.
   5a.2. 사용자에게 시스템 안정화를 위한 재접속을 요청한다.
   
RELATED INFORMATION
FIELD-VALUE
Performance: 데이터 패키징 및 서버 전송 과정은 5초 이내에 완료되어야 함.
Frequency: 반려동물 1개체당 최종 단계에서 1회 발생.
Concurrency: 없음.
Due Date: 

Use Case #9 : 추억 기록 출력
Summary - 독립하여 ‘동물 세상’으로 떠난 반려동물을 다시 호출하여 과거 육성 과정에서 쌓인 활동 로그를 바탕으로 특별한 재회 메시지를 출력한다.
Scope - LOG-PET
Level - User Level
Author - 
Last Update - 2026-05-08
Status - Analysis
Primary Actor - Owner, World Server
Preconditions -1. 최소 한 마리 이상의 반려동물이 독립하여 World Server에 데이터가 보존되어 있어야 한다.
               2. 월드 서버와의 통신이 원활해야 한다.
Trigger - 메인 메뉴의 [추억 보기] 또는 [동물 세상 방문] 버튼을 선택한다.
Success Post Condition - 과거 Activity Log에서 무작위로 추출된 추억 데이터를 바탕으로 생성된 ‘회상 대화’가 화면에 출력된다.
Failed Post Condition - 데이터 호출 실패 시 "추억을 불러올 수 없습니다"라는 메시지를 출력하며 초기 화면으로 복귀한다.

Step-Action
S. 떠나보낸 반려동물과 재회하여 과거의 기록을 바탕으로 교감한다.
1. 사용자가 동물 세상 메뉴에서 보고 싶은 반려동물을 리스트에서 선택한다.
2. 시스템은 World Server에 해당 동물의 과거 Activity Log 뭉치를 요청한다.
3. 시스템은 수신된 수많은 로그 중 재회 알고리즘을 통해 하나의 특정 사건을 랜덤 추출한다.
4. 시스템은 추출된 데이터를 대사 템플릿에 주입한다.
5. 시스템은 동물의 이미지와 함께 "주인님, 그때 주셨던 사과 정말 맛있었어요!"와 같은 회상 대사를 출력한다.
6. 사용자가 대화를 확인하고 정서적 위안을 얻으며 종료된다.
  
Step-Branching Action
3- 3a. 과거 활동 로그가 너무 적어 대사 생성이 어려운 경우
   3a.1. 시스템은 활동 로그 대신 동물의 성격이나 종의 특성을 반영한 기본 그리움 메시지를 출력한다.
4- 4a. 데이터 매핑 오류로 대사 템플릿이 깨지는 경우
   4a.1. 시스템은 예외 처리를 통해 "다시 만나서 반가워요!"와 같은 범용적인 인사말로 대체한다.
5- 5a. 서버 응답 지연으로 데이터 로딩이 길어지는 경우
   5a.1. 시스템은 로딩 중임을 알리는 애니메이션을 보여주며 5초 초과 시 재시도 버튼을 활성화한다.
   
RELATED INFORMATION
FIELD-VALUE
Performance: 서버에서 로그를 호출하고 대사로 변환하여 출력하기까지 3초 미만이어야 함.
Frequency:사용자가 추억 기능을 이용할 때마다 발생.
Concurrency:없음.
Due Date: 

Use Case #10 : 일기 작성 및 교감 
Summary - 사용자가 하루의 일상을 텍스트로 기록하면 시스템이 이를 분석하여 반려동물과의 친밀도를 높이고 성장에 필요한 경험치를 부여하는 핵심 교감 시스템이다.
Scope - LOG-PET
Level - User Level
Author - 
Last Update - 2026-05-08
Status - Analysis
Primary Actor - Owner
Preconditions -1. 사용자가 로그인 상태여야 한다.
               2. 반려동물이 등록되어 활성화된 상태여야 한다.
Trigger - 메인 화면 또는 일기 메뉴에서 [오늘의 일기 쓰기] 버튼을 선택한다.
Success Post Condition - 일기 내용이 Storage DB에 저장되고 분석된 가중치에 따라 경험치가 상승하며 동물의 즉각적인 반응이 출력된다.
Failed Post Condition - 일기 저장 실패 시 수치 변화가 일어나지 않으며 작성 중이던 텍스트가 유실되지 않도록 임시 저장 상태를 유지한다.

Step-Action
S. 사용자가 일기를 작성하여 반려동물과 정서적으로 교감하고 성장을 도모한다.
1. 사용자는 일기 작성란에 오늘 있었던 사건이나 감정을 텍스트로 자유롭게 입력한다.
2. 사용자가 작성 완료 버튼을 누르면, 시스템은 입력된 전체 텍스트의 길이를 분석한다.
3. 시스템은 분석된 텍스트 양에 비례하여 친밀도 점수와 경험치(EXP) 가중치를 산출한다.
4. 산출된 수치를 현재 반려동물의 데이터 스탯에 즉각 합산하여 반영한다.
5. 시스템은 작성된 일기 본문과 작성 시각을 포함한 Activity Log 객체를 생성하여 Storage DB에 저장한다.
6. 시스템은 일기 작성을 인지한 반려동물의 특별 애니메이션과 감사 메시지를 화면에 출력한다.

Step-Branching Action
2- 2a. 작성된 텍스트가 너무 짧은 경우 
   2a.1. 시스템은 성의 있는 기록을 유도하기 위해 "조금 더 자세히 들려주세요!"라는 가이드를 제시한다.
   2a.2. 최소 기준 미달 시 보상 수치를 평소보다 낮게 책정하거나 부여하지 않는다.
5- 5a. 파일 시스템 쓰기 오류로 일기 저장이 실패한 경우
   5a.1. 시스템은 "일기 저장 중 오류가 발생했습니다" 알림을 띄우고 작성한 내용을 클립보드에 복사하거나 임시 보관한다.
   5a.2. 데이터 정합성을 위해 3번에서 산출된 수치 상승분을 롤백한다.
6- 6a. 특정 키워드나 감정 패턴이 감지된 경우 
   6a.1. 시스템은 감정 분석 엔진을 통해 동물이 그에 맞는 위로 혹은 축하 대사를 하도록 설정한다.
   
RELATED INFORMATION
FIELD-VALUE
Performance: 텍스트 분석 및 데이터 로그 저장 프로세스는 2초 이내에 완료되어야 함.
Frequency: 사용자가 일상을 공유하고 싶을 때 수시로 발생 .
Concurrency: 없음.
Due Date: 

# 3.Domain Analysis
1) Main_Engine (Logic Controller)
시스템의 모든 시뮬레이션 과정이 이 클래스를 통해 시행된다. 육성 시스템의 핵심 로직을 담당하며, 시간 흐름에 따른 스탯 변화 계산 및 다른 모든 클래스의 Operation을 제어하고 변경한다.

2) Registration (Account Creator)
사용자가 시스템을 이용하기 위한 권한을 부여받는 클래스이다. 아이디와 비밀번호를 입력받아 중복 여부를 확인하며, 이 클래스를 통해 생성된 계정 정보만이 Storage_DB에 영구 저장되어 로그인 권한을 얻는다.

3) Login (Authenticator)
시스템 접근을 위해 실행해야 하는 클래스이다. 사용자가 입력한 정보와 Storage_DB의 데이터를 대조하여 누구인지 판별하고, 인증 성공 시 해당 사용자의 반려동물 인스턴스를 시스템에 활성화한다.

4) Pet_Instance (Digital Life Object)
반려동물 그 자체를 정의하는 클래스이다. 동물의 이름, 종(Species), 성장 단계(GrowthStage) 등의 Attribute를 가지며, 주인의 상호작용에 따라 수시로 상태 값이 변경되는 핵심 도메인 모델이다.

5) Status_Monitor (Inquire Status)
사용자가 반려동물의 현재 욕구 수치(허기, 청결, 친밀도 등)를 알고 싶을 때 정보를 요청하는 클래스이다. Status_Manager에 기록된 현재 수치를 시각화하여 사용자에게 공개한다.

6) Interaction_Manager (Management)
사용자가 먹이 주기, 산책, 씻기기 등의 명령을 내릴 때 이를 처리하는 클래스이다. 액션에 따른 가중치를 계산하여 Status_Manager에 반영하며, 수행된 모든 활동을 로그로 기록한다.

7) Diary_Analyzer (Communication Core)
사용자가 입력한 일기 텍스트를 분석하는 클래스이다. 글자 수와 빈도 등을 계산하여 친밀도와 경험치 가중치를 산출하고, 이를 Pet_Instance의 스탯에 반영하도록 요청한다.

8) Growth_Controller (Evolution Logic)
반려동물의 성장 조건을 판단하고 전이를 수행하는 클래스이다. 경험치와 경과 시간이 기준치에 도달하면 Pet_Instance의 외형 클래스를 아기에서 성체로 변경(다형성 활용)하고 리소스를 갱신한다.

9) Time_Synchronizer (Data Integrity)
외부 Time Server와 통신하여 시간 정합성을 맞추는 클래스이다. 접속 시 표준 시간을 가져와 Storage_DB에 기록된 마지막 접속 시간과의 차이를 계산하고, 부재 중 손실된 스탯을 산출한다.

10) Activity_Logger (Log Recorder)
시스템 내에서 발생하는 모든 상호작용 및 일기 내용을 기록하는 클래스이다. 이 정보는 추후 동물이 독립했을 때 Recall_Conversation을 생성하기 위한 기초 데이터가 된다.

11) Storage_DB (File System Wrapper)
가상 서버의 데이터베이스 역할을 수행하는 클래스이다. 모든 사용자 계정, 반려동물 스탯, 활동 로그를 텍스트 파일 형태로 저장하고 읽어오는 기능을 담당한다.

12) Independence_Manager (Releasement)
최종 성장한 동물을 시스템에서 해방시키는 과정을 관리하는 클래스이다. 로컬 데이터를 정리하고 모든 기록을 World_Server로 전송하기 위한 패키징 작업을 수행한다.

13) World_Server_Linker (External Archive)
독립한 동물들의 데이터를 영구 보존하는 가상 서버 연결 클래스이다. Independence_Manager로부터 받은 데이터를 저장하고, 추후 추억 회상 시 데이터를 다시 제공한다.

14) Recall_Generator (Memory Recovery)
사용자가 독립한 동물과 재회할 때 실행되는 클래스이다. World_Server_Linker를 통해 과거 Activity_Logger에 기록된 내용을 무작위로 추출하여 대사 템플릿에 주입한다.

15) Status_Manager (Reflection)
Interaction_Manager와 Diary_Analyzer의 실행 결과를 실시간으로 스탯에 반영(Reflection)한다. Status_Monitor에게는 현재 수치 정보를 주고, Growth_Controller에게는 성장 가능 여부를 알려준다.

# 4. User Interface prototype

1. Main_Engine
```mermaid
graph TD

    classDef device fill:#fff,stroke:#000,stroke-width:2px,rx:15,ry:15,color:#000;
    classDef logo fill:none,stroke:none,color:#000,font-size:20px;
    classDef text fill:none,stroke:none,color:#333;
    classDef input fill:#f4f4f4,stroke:#d0d0d0,stroke-width:1px,color:#666,rx:5,ry:5;
    classDef button_solid fill:#333,stroke:#000,stroke-width:1px,color:#fff,rx:5,ry:5;
    classDef button_line fill:#fff,stroke:#333,stroke-width:1px,color:#333,rx:5,ry:5;

    subgraph Mobile_Frame [LOG-PET App v1.0]
        direction TB

        Top_Space[ ]:::text
        Logo["🐾 LOG-PET"]:::logo
        Title["디지털 생명체 육성 시뮬레이션"]:::text
        
        Mid_Space1[ ]:::text
        Input_ID["&nbsp;&nbsp;&nbsp;아이디 (ID) 입력"]:::input
        Input_PW["&nbsp;&nbsp;&nbsp;비밀번호 (PW) 입력"]:::input
        
        Mid_Space2[ ]:::text
        Btn_Login["로 그 인"]:::button_solid
        
        Line["--------------------------------"]:::text
        
        Btn_SignUp["처음이신가요? 회원가입"]:::button_line
        

        Top_Space --- Logo
        Logo --- Title
        Title --- Mid_Space1
        Mid_Space1 --- Input_ID
        Input_ID --- Input_PW
        Input_PW --- Mid_Space2
        Mid_Space2 --- Btn_Login
        Btn_Login --- Line
        Line --- Btn_SignUp
    end

    class Mobile_Frame device;
```
2.Registration
```mermaid
graph TD
    classDef device fill:#fff,stroke:#000,stroke-width:2px,rx:15,ry:15,color:#000;
    classDef title fill:none,stroke:none,color:#000,font-size:18px,font-weight:bold;
    classDef text fill:none,stroke:none,color:#333,font-size:12px;
    classDef input fill:#f4f4f4,stroke:#d0d0d0,stroke-width:1px,color:#666,rx:5,ry:5;
    classDef input_filled fill:#fff,stroke:#333,stroke-width:1px,color:#000,font-weight:bold,rx:5,ry:5;
    classDef button_solid fill:#333,stroke:#000,stroke-width:1px,color:#fff,rx:5,ry:5;

    subgraph Mobile_Frame [LOG-PET Register]
        direction TB

        Nav["⬅️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 회원가입"]:::title
        
        Space1[ ]:::text
        Label1["아이디"]:::text
        In_ID["&nbsp;&nbsp;eu"]:::input_filled
        
        Label2["비밀번호"]:::text
        In_PW["&nbsp;&nbsp;123"]:::input_filled
        
        Label3["비밀번호 확인 (6자 이상 권장)"]:::text
        In_PW2["&nbsp;&nbsp;***"]:::input_filled
        
        Space2[ ]:::text
        Btn_Reg["가 입 완 료"]:::button_solid
        
        Nav --- Space1
        Space1 --- Label1
        Label1 --- In_ID
        In_ID --- Label2
        Label2 --- In_PW
        In_PW --- Label3
        Label3 --- In_PW2
        In_PW2 --- Space2
        Space2 --- Btn_Reg
    end

    class Mobile_Frame device;
```
3.Login
```mermaid
graph TD

    classDef device fill:#fff,stroke:#000,stroke-width:2px,rx:15,ry:15,color:#000;
    classDef title fill:none,stroke:none,color:#000,font-size:18px,font-weight:bold;
    classDef text fill:none,stroke:none,color:#333,font-size:12px;
    classDef input fill:#f4f4f4,stroke:#d0d0d0,stroke-width:1px,color:#666,rx:5,ry:5;
    classDef input_filled fill:#fff,stroke:#333,stroke-width:1px,color:#000,font-weight:bold,rx:5,ry:5;
    classDef button_solid fill:#333,stroke:#000,stroke-width:1px,color:#fff,rx:5,ry:5;
    classDef error fill:none,stroke:#ff0000,stroke-width:1px,color:#ff0000,font-size:11px,rx:10,ry:10;


    subgraph Mobile_Frame [LOG-PET Login]
        direction TB

        Nav["⬅️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 로그인"]:::title
        
        Space1[ ]:::text
        Logo["🐾"]:::title
        LogoText["반가워요! 다시 오셨군요."]:::text
        
        Space2[ ]:::text
        In_ID["&nbsp;&nbsp;eu"]:::input_filled
        In_PW["&nbsp;&nbsp;***"]:::input_filled
        
        Err1["아이디 또는 비밀번호가 일치하지 않습니다."]:::error
        
        Space3[ ]:::text
        Btn_Login["로 그 인"]:::button_solid
        
        Find_Link["아이디 / 비밀번호 찾기"]:::text

        Nav --- Space1
        Space1 --- Logo
        Logo --- LogoText
        LogoText --- Space2
        Space2 --- In_ID
        In_ID --- In_PW
        In_PW --- Err1
        Err1 --- Space3
        Space3 --- Btn_Login
        Btn_Login --- Find_Link
    end

    class Mobile_Frame device;
```
4.Pet_Instance
```mermaid
graph TD
    classDef device fill:#fff,stroke:#000,stroke-width:2px,rx:15,ry:15,color:#000;
    classDef title fill:none,stroke:none,color:#000,font-size:18px,font-weight:bold;
    classDef text fill:none,stroke:none,color:#333,font-size:12px;
    classDef input_filled fill:#fff,stroke:#333,stroke-width:1px,color:#000,font-weight:bold,rx:5,ry:5;
    classDef btn_active fill:#333,stroke:#000,stroke-width:1px,color:#fff,rx:5,ry:5;
    classDef btn_inactive fill:#fff,stroke:#ccc,stroke-width:1px,color:#ccc,rx:5,ry:5;

    subgraph Mobile_Frame [LOG-PET : New Friend]
        direction TB

        Nav["⬅️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 반려동물 등록"]:::title
        
        Space1[ ]:::text
        Instruction["함께할 친구의 정보를 입력해주세요."]:::text
        
        Label1["이름 부여"]:::text
        In_Name["&nbsp;&nbsp;초코"]:::input_filled
        
        Label2["종 선택 (Species)"]:::text
        subgraph Species_Select [Selection]
            direction LR
            Sel1["🐕 강아지"]:::btn_active
            Sel2["🐈 고양이"]:::btn_inactive
            Sel3["🐹 햄스터"]:::btn_inactive
        end

        Space2[ ]:::text
        Btn_Create["생 성 하 기"]:::btn_active
        
        Nav --- Space1
        Space1 --- Instruction
        Instruction --- Label1
        Label1 --- In_Name
        In_Name --- Label2
        Label2 --- Species_Select
        Species_Select --- Space2
        Space2 --- Btn_Create
    end

    class Mobile_Frame device;
```

5.Status_Monitor
```mermaid
graph TD
    classDef device fill:#fff,stroke:#000,stroke-width:2px,rx:15,ry:15,color:#000;
    classDef title fill:none,stroke:none,color:#000,font-size:18px,font-weight:bold;
    classDef pet_frame fill:#f9f9f9,stroke:#eeeeee,stroke-width:1px,rx:10,ry:10;
    classDef pet_icon fill:none,stroke:none,color:#000,font-size:45px;
    classDef gauge_box fill:#ffffff,stroke:#333,stroke-width:1px,rx:5,ry:5,color:#000,font-size:11px;
    classDef footer fill:#333,stroke:#000,color:#fff,rx:5,ry:5;

    subgraph Mobile_Frame [LOG-PET : Dashboard]
        direction TB
        Header["👤 eu &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ⚙️"]:::title

        subgraph Pet_Area [Cute Choco]
            direction TB
            Dog_Icon["🐶"]:::pet_icon
            Pet_Name["초코 (Baby Dog)"]:::title
            Pet_Desc["말랑말랑한 젤리 발바닥!"]:::title
        end

        subgraph Stats_Horizontal [Status Monitor]
            direction LR
            Stat1["🍴 배고픔<br>80%<br>[■■■■□]"]:::gauge_box
            Stat2["🧼 청결도<br>60%<br>[■■■□□]"]:::gauge_box
            Stat3["❤️ 호감도<br>40%<br>[■■□□□]"]:::gauge_box
        end

        Space[ ]:::title
        subgraph Menu [Interaction]
            direction LR
            Btn1["식사하기"]:::footer
            Btn2["씻기기"]:::footer
            Btn3["일기쓰기"]:::footer
        end

        Header --- Pet_Area
        Pet_Area --- Stats_Horizontal
        Stats_Horizontal --- Space
        Space --- Menu
    end
    class Mobile_Frame device;
    class Pet_Area pet_frame;
```

6.Interaction_Manager 
```mermaid
graph TD

    classDef device fill:#fff,stroke:#000,stroke-width:2px,rx:15,ry:15,color:#000;
    classDef title fill:none,stroke:none,color:#000,font-size:18px,font-weight:bold;
    classDef text fill:none,stroke:none,color:#333,font-size:12px;
    classDef pet_icon fill:none,stroke:none,color:#000,font-size:40px;
    classDef action_btn fill:#fff,stroke:#333,stroke-width:1px,color:#000,rx:10,ry:10;
    classDef active_btn fill:#333,stroke:#000,stroke-width:1px,color:#fff,rx:10,ry:10;

    subgraph Mobile_Frame [LOG-PET : Interaction]
        direction TB


        Nav["⬅️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 활동 선택"]:::title
        

        Space1[ ]:::text
        Pet_Icon["🐶"]:::pet_icon
        Status_Text["초코가 배가 고픈 것 같아요!"]:::text
        
        subgraph Interaction_Menu [Select Action]
            direction TB
            Btn1["🍚 맛있는 식사 주기 (배고픔 +20)"]:::active_btn
            Btn2["🧼 깨끗하게 씻기기 (청결도 +20)"]:::action_btn
            Btn3["🎾 즐겁게 공놀이 (호감도 +10)"]:::action_btn
        end
        
        Space2[ ]:::text
        Info["* 활동 시 에너지가 소모될 수 있습니다."]:::text

        Nav --- Space1
        Space1 --- Pet_Icon
        Pet_Icon --- Status_Text
        Status_Text --- Interaction_Menu
        Interaction_Menu --- Space2
        Space2 --- Info
    end

    class Mobile_Frame device;
```

7. Diary_Analyzer
```mermaid
graph TD

    classDef device fill:#fff,stroke:#000,stroke-width:2px,rx:15,ry:15,color:#000;
    classDef title fill:none,stroke:none,color:#000,font-size:18px,font-weight:bold;
    classDef text fill:none,stroke:none,color:#333,font-size:12px;
    classDef input_area fill:#f9f9f9,stroke:#d0d0d0,stroke-width:1px,color:#000,rx:5,ry:5;
    classDef result_box fill:#f0f0f0,stroke:#333,stroke-width:1px,color:#000,font-weight:bold,rx:10,ry:10;
    classDef btn_black fill:#333,stroke:#000,stroke-width:1px,color:#fff,rx:5,ry:5;
    subgraph Mobile_Frame [LOG-PET : Diary]
        direction TB

        Nav["⬅️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 일기 쓰기"]:::title
        
        Space1[ ]:::text
        Date["2026년 5월 8일 (금)"]:::text
        
        Input_Box["&nbsp;&nbsp;오늘 초코랑 산책을 다녀왔다.<br>&nbsp;&nbsp;바람이 시원해서 초코가 정말<br>&nbsp;&nbsp;좋아하는 것 같아 나도 행복했다!"]:::input_area
        
        Btn_Analyze["일 기 분 석 하 기"]:::btn_black
        
        subgraph Analysis_Result [Analyzer Output]
            direction TB
            Res_Title["✨ 분석이 완료되었습니다! ✨"]:::text
            Res_Stat["경험치(EXP) +50<br>호감도(Affinity) +15"]:::result_box
        end

        Nav --- Space1
        Space1 --- Date
        Date --- Input_Box
        Input_Box --- Btn_Analyze
        Btn_Analyze --- Analysis_Result
    end

    class Mobile_Frame device;
```

8.Growth_Controller
```mermaid
graph TD
    classDef device fill:#fff,stroke:#000,stroke-width:2px,rx:15,ry:15,color:#000;
    classDef title fill:none,stroke:none,color:#000,font-size:18px,font-weight:bold;
    classDef text fill:none,stroke:none,color:#333,font-size:12px;
    classDef evol_box fill:#f9f9f9,stroke:#000,stroke-dasharray: 5 5,rx:20,ry:20;
    classDef pet_icon fill:none,stroke:none,color:#000,font-size:50px;
    classDef btn_black fill:#333,stroke:#000,stroke-width:1px,color:#fff,rx:5,ry:5;

    subgraph Mobile_Frame [LOG-PET : Evolution]
        direction TB

        Space1[ ]:::text
        Title["✨ CONGRATULATIONS! ✨"]:::title
        

        subgraph Evol_Effect [Transformation]
            direction LR
            Before["🐶<br>Baby"]:::text
            Arrow["➡️"]:::text
            After["🐕<br>Adult"]:::pet_icon
        end
        
        Desc["초코가 듬직한 성체가 되었습니다!"]:::text
        
        subgraph New_Stats [Updated Info]
            direction TB
            S1["성장 단계 : Baby ➔ Adult"]:::text
            S2["새로운 활동이 해제되었습니다."]:::text
        end
        
        Btn_Confirm["우와! 확인"]:::btn_black

        Space1 --- Title
        Title --- Evol_Effect
        Evol_Effect --- Desc
        Desc --- New_Stats
        New_Stats --- Btn_Confirm
    end

    class Mobile_Frame device;
    class Evol_Effect evol_box;
```

9. Time_Synchronizer
```mermaid
graph TD
    classDef device fill:#fff,stroke:#000,stroke-width:2px,rx:15,ry:15,color:#000;
    classDef title fill:none,stroke:none,color:#000,font-size:16px,font-weight:bold;
    classDef sync_card fill:#f4f4f4,stroke:#d0d0d0,stroke-width:1px,color:#333,rx:10,ry:10;
    classDef stat_down fill:none,stroke:none,color:#ff0000,font-size:12px;

    subgraph Mobile_Frame [LOG-PET : Sync]
        direction TB

        Header["다시 만나서 반가워요!"]:::title
        
        subgraph Sync_Report [Time Sync Report]
            direction TB
            Last_Login["마지막 접속: 8시간 전"]:::text
            Status["초코는 잠시 외로웠나봐요..."]:::text
        end
        
        subgraph Decay_List [Stat Changes]
            direction TB
            D1["🍴 배고픔 -20"]:::stat_down
            D2["🧼 청결도 -10"]:::stat_down
            D3["❤️ 호감도 -5"]:::stat_down
        end
        

        Btn_Care["지금 바로 돌봐주기"]:::btn_black
        

        Header --- Sync_Report
        Sync_Report --- Decay_List
        Decay_List --- Btn_Care
    end

    class Mobile_Frame device;
    class Sync_Report sync_card;
```

10.Activity_Logger
```mermaid
graph TD

    classDef device fill:#fff,stroke:#000,stroke-width:2px,rx:15,ry:15,color:#000;
    classDef title fill:none,stroke:none,color:#000,font-size:18px,font-weight:bold;
    classDef log_item fill:#fff,stroke:#eeeeee,stroke-width:1px,color:#333,rx:8,ry:8;
    classDef time_text fill:none,stroke:none,color:#999,font-size:11px;
    classDef diary_preview fill:none,stroke:none,color:#666,font-size:12px,font-style:italic;

    subgraph Mobile_Frame [LOG-PET : Diary Logs]
        direction TB

        Header["📖 일기장"]:::title
        
        
        subgraph Log1 [Entry 1]
            direction TB
            T1["2026-05-08 14:15"]:::time_text
            C1["오늘 초코랑 산책을 다녀왔다. 바람이 시원해서..."]:::diary_preview
        end
        
        subgraph Log2 [Entry 2]
            direction TB
            T2["2026-05-07 20:30"]:::time_text
            C2["오늘은 일이 너무 힘들었다..."]:::diary_preview
        end
        
        subgraph Log3 [Entry 3]
            direction TB
            T3["2026-05-06 11:10"]:::time_text
            C3["엄마랑 전을 해먹었다..."]:::diary_preview
        end
        
        subgraph Log4 [Entry 4]
            direction TB
            T4["2026-05-05 09:00"]:::time_text
            C4["오늘 초코가 엄청 더럽다. 뽀득뽀득 샤워날~..."]:::diary_preview
        end

        Header --- Log1
        Log1 --- Log2
        Log2 --- Log3
        Log3 --- Log4
    end

    class Mobile_Frame device;
    class Log1,Log2,Log3,Log4 log_item;
```

11.Storage_DB
```mermaid
graph TD

    classDef device fill:#fff,stroke:#000,stroke-width:2px,rx:15,ry:15,color:#000;
    classDef title fill:none,stroke:none,color:#000,font-size:16px,font-weight:bold;
    classDef db_card fill:#f9f9f9,stroke:#d0d0d0,stroke-width:1px,color:#333,rx:10,ry:10;
    classDef save_btn fill:#333,stroke:#000,stroke-width:1px,color:#fff,rx:5,ry:5;
    classDef file_text fill:none,stroke:none,color:#666,font-family:monospace,font-size:11px;


    subgraph Mobile_Frame [LOG-PET : Storage]
        direction TB


        Header["시스템 데이터 관리"]:::title
        

        subgraph Storage_Info [Current Storage Status]
            direction TB
            S1["사용자 계정: eu.txt (Saved)"]:::file_text
            S2["반려동물 스탯: choco_stat.txt (Saved)"]:::file_text
            S3["활동 로그: activity_log.txt (68kb)"]:::file_text
        end
        

        Space[ ]:::title
        Btn_Backup["전체 데이터 백업 실행"]:::save_btn
        
        Notice["* 모든 데이터는 기기 내 가상 서버 영역에<br>안전하게 암호화되어 보존됩니다."]:::file_text


        Header --- Storage_Info
        Storage_Info --- Space
        Space --- Btn_Backup
        Btn_Backup --- Notice
    end


    class Mobile_Frame device;
    class Storage_Info db_card;
```

12.Independence_Manager
```mermaid
graph TD

    classDef device fill:#fff,stroke:#000,stroke-width:2px,rx:15,ry:15,color:#000;
    classDef title fill:none,stroke:none,color:#000,font-size:18px,font-weight:bold;
    classDef message_box fill:#f4f4f4,stroke:#333,stroke-width:1px,rx:15,ry:15;
    classDef pet_icon fill:none,stroke:none,color:#000,font-size:40px;
    classDef btn_black fill:#333,stroke:#000,stroke-width:1px,color:#fff,rx:5,ry:5;

    subgraph Mobile_Frame [LOG-PET : Graduation]
        direction TB


        Header["아름다운 이별"]:::title
        

        Space1[ ]:::title
        Pet_Icon["🐕"]:::pet_icon
        
        subgraph Farewell_Msg [Choco's Message]
            direction TB
            Msg["'eu님과 함께한 시간들 덕분에<br>이제 저는 혼자서도 잘 지낼 수 있어요.<br>정말 고마웠어요!'"]:::title
        end

        Btn_Release["초코의 독립 응원하기"]:::btn_black
        
        Desc["* 독립한 동물의 기록은 '추억 회상' 메뉴에서<br>언제든 다시 꺼내 볼 수 있습니다."]:::title
        Header --- Space1
        Space1 --- Pet_Icon
        Pet_Icon --- Farewell_Msg
        Farewell_Msg --- Btn_Release
        Btn_Release --- Desc
    end

    class Mobile_Frame device;
    class Farewell_Msg message_box;
```

13.World_Server_Linker
```mermaid
graph TD
    classDef device fill:#fff,stroke:#000,stroke-width:2px,rx:15,ry:15,color:#000;
    classDef server_box fill:#eeeeee,stroke:#333,stroke-width:1px,rx:10,ry:10;
    classDef transfer_text fill:none,stroke:none,color:#000,font-size:12px,font-weight:bold;

    subgraph Mobile_Frame [LOG-PET : World Link]
        direction TB

        Header["월드 서버 데이터 전송"]:::title
        
        subgraph Link_Process [Data Transferring...]
            direction TB
            From["[ 내 폰 (Local) ]"]:::transfer_text
            Arrow["⬇️<br>데이터 암호화 패키징 중...<br>⬇️"]:::transfer_text
            To["[ 월드 서버 (Archive) ]"]:::transfer_text
        end

        Progress["전송 완료 (100%)"]:::save_btn
        
        Status_Msg["초코의 기록이 성좌의 숲 서버에<br>성공적으로 안착되었습니다."]:::transfer_text

        Header --- Link_Process
        Link_Process --- Progress
        Progress --- Status_Msg
    end

    class Mobile_Frame device;
    class Link_Process server_box;
```

14.Recall_Generator
```mermaid
graph TD
    classDef device fill:#fff,stroke:#000,stroke-width:2px,rx:15,ry:15,color:#000;
    classDef title fill:none,stroke:none,color:#000,font-size:16px,font-weight:bold;
    classDef msg_box fill:#f0f0f0,stroke:#333,stroke-width:1px,rx:15,ry:15;
    classDef pet_icon_s fill:none,stroke:none,color:#000,font-size:30px;
    classDef btn_line fill:#fff,stroke:#333,stroke-width:1px,color:#333,rx:5,ry:5;

    subgraph Mobile_Frame [LOG-PET : Memory]
        direction TB
        Header["⬅️ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 추억 회상"]:::title
        
        Space1[ ]:::title
        Pet_Icon["🐕"]:::pet_icon_s
        Pet_Name["초코 (Adult)"]:::title
        
        subgraph Chat_Area [Recall Conversation]
            direction TB
            Date["2026.04.10 기록으로부터"]:::title
            Message["'eu님! 우리 같이 산책하며<br>일기 썼던 날 기억나요?<br>그때 사과 정말 맛있었는데...'"]:::title
        end
        
        Btn_Next["다른 추억 꺼내기"]:::btn_line
        Btn_Exit["세상으로 돌려보내기"]:::btn_line

        Header --- Space1
        Space1 --- Pet_Icon
        Pet_Icon --- Pet_Name
        Pet_Name --- Chat_Area
        Chat_Area --- Btn_Next
        Btn_Next --- Btn_Exit
    end
    class Mobile_Frame device;
    class Chat_Area msg_box;
```

15.Status_Manager
```mermaid
graph TD
    classDef device fill:#fff,stroke:#000,stroke-width:2px,rx:15,ry:15,color:#000;
    classDef title fill:none,stroke:none,color:#000,font-size:16px,font-weight:bold;
    classDef sync_box fill:#f9f9f9,stroke:#000,stroke-dasharray: 5 5,rx:10,ry:10;
    classDef btn_black fill:#333,stroke:#000,stroke-width:1px,color:#fff,rx:5,ry:5;

    subgraph Mobile_Frame [LOG-PET : Reflection]
        direction TB
        Header["데이터 실시간 동기화"]:::title
        
        subgraph Sync_Engine [Reflection Engine]
            direction TB
            In1["입력: 일기 분석 완료 (+50 EXP)"]:::title
            In2["입력: 상호작용 (식사 +20)"]:::title
            Arrow["▼"]:::title
            Update["[ Status_Manager 반영 중 ]"]:::btn_black
        end
        
        subgraph Output_Result [Reflection Result]
            direction LR
            Out1["상태창 갱신"]:::sync_box
            Out2["DB 파일 저장"]:::sync_box
        end
        
        Status["모든 데이터가 일치합니다."]:::title

        Header --- Sync_Engine
        Sync_Engine --- Output_Result
        Output_Result --- Status
    end
    class Mobile_Frame device;
```

# 5. Glossary
사용자 :	반려동물을 입양하여 육성하고 일기를 작성하는 주체 (Consumer 역할)
시스템 관리자 : 전체 가상 서버와 사용자 계정 및 로그 데이터를 관리하는 주체
반려동물 :	시스템 내에서 사용자와 상호작용하며 성장하는 디지털 생명체 객체
성장 단계 :	반려동물의 성숙도를 나타내며, 경험치에 따라 Baby에서 Adult로 진화함
상태 수치 :	반려동물의 현재 욕구(배고픔, 청결도, 호감도)를 나타내는 정량적 데이터
상호작용 :	식사 제공, 씻기기 등 사용자가 반려동물의 상태를 변화시키는 모든 행위
성장 다이어리 :	사용자의 일상을 기록하고, 이를 분석하여 반려동물의 성장에 반영하는 매개체
경험치 :	일기 작성 및 상호작용을 통해 축적되는 수치로, 진화의 핵심 기준임
활동 로그 :	사용자와 반려동물 사이에서 발생한 모든 사건이 기록된 데이터 파일
가상 서버 :	독립한 반려동물의 데이터가 영구적으로 보존되는 외부 아카이브 영역
추억 회상 :	월드 서버에 저장된 과거 로그를 기반으로 독립한 동물과 재회하는 기능
데이터 반영 :	모든 입력값과 활동 결과가 시스템 스탯 및 DB에 실시간으로 동기화되는 과정

# 6.References
- Mermaid.js Documentation// (https://mermaid.js.org/)
- GitHub Flavored Markdown (GFM)//(https://github.github.com/gfm/)
- file//[Analysis] Example2.pdf
