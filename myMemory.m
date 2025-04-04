classdef myMemory < handle
    % myMemory class
    % 自分専用の単語登録 & 学習機能を持つクラス

    properties
        T table % Table variable
        learningDataIndices uint16 % 学習するデータインデックス
        uName = "user" % User name
    end

    methods
        function obj = myMemory(T)
            % myEitan クラスのコンストラクタ
            % テーブルを定義

            % テーブルのコラム名
            VariableNames = [{'word'},{'meaning'},{'ex'},{'nLearn'},{'nWrong'},{'pWrong'},{'regDay'}];

            if nargin > 0
                if isequal(T.Properties.VariableNames,VariableNames)
                    obj.T = T; % 入力テーブルのセット
                else
                    error('Wrong Table Format');
                end
            else
                T = table('Size',[1,7],...
                    'VariableTypes',["string","string","string","int16","int16","single","datetime"],...
                    'VariableNames',VariableNames);
                T(1,:) = [];
                obj.T = T; % 空の table を登録
            end
        end

        function set.T(obj,T)
            % プロパティ T の setter method
            % テーブルを定義
            try
                obj.T = T;
            catch ME
                error("Format of the input table is wrong.")
            end
        end

        function set.uName(obj,uName)
            try
                if ischar(uName)
                    uName = string(uName);
                end
                obj.uName = uName;
            catch ME
                error(ME.message)
            end
        end

        function addWord(obj,varargin)
            % addWord 単語を追加して登録
            % addWord(word,meaning,explanation)
            %
            % addWord(word,~,explanation)
            %

            word = varargin{1};
            meaning = varargin{2};
            ex = varargin{3};

            st4Tbl.word = word;
            st4Tbl.meaning = meaning;
            st4Tbl.ex = ex;
            st4Tbl.nLearn = 1;
            st4Tbl.nWrong = 1;
            st4Tbl.pWrong = 1;
            st4Tbl.regDay = datetime("today");

            obj.T = [obj.T; struct2table(st4Tbl)];
        end

        function deleteWords(obj,idxORwords)
            %deleteWords 単語を削除
            %
            % deleteWords(idces)
            % deleteWords(words)
            
            if isnumeric(idxORwords)
                obj.T(idxORwords,:) = [];
            elseif isstring(idxORwords)
                indcs = find(obj.T.word==idxORwords);
                obj.T(indcs,:) = [];
            else
                error("Wrong input");
            end
        end

        function swapWordMeaning(obj)
            % swapWordMeaning
            % Word <-> Meaning を交換
            %
            words = obj.T.word;
            obj.T.word = obj.T.meaning;
            obj.T.meaning = words;
        end

        function learning(obj,numQuestion,varargin)
            % learning 学習
            % 
            % learning(numOfQuestions, method)
            %
            
            % number of questions
            numQuestion = min(height(obj.T),numQuestion);
            % selection method
            method = "default";
            if nargin > 2
                method = varargin{1};
            end
            
            switch method
                case "nLearn"
                    [~,indices] = sortrows(obj.T,["nLearn","regDay"],["ascend","ascend"]);
                    indices = indices';
                case "pWrong"
                    [~,indices] = sortrows(obj.T,["pWrong","regDay","nLearn"],["descend","ascend","ascend"]);
                    indices = indices';
                case "nWrong"
                    [~,indices] = sortrows(obj.T,["nWrong","regDay","nLearn"],["descend","ascend","ascend"]);
                    indices = indices';
                otherwise
                    %indices = randperm(height(obj.T)); % Change default
                    [~,indices] = sortrows(obj.T,["regDay","nLearn"],["ascend","ascend"]);
                    indices = indices';
            end

            % Learning data indices & Shuffle it
            rng("shuffle");
            obj.learningDataIndices = indices(1:numQuestion);
            obj.learningDataIndices = obj.learningDataIndices(randperm(numQuestion));
        end

        function showMyTable(obj,k,col)
            % showMyTable 単語テーブルを表示 
            %
            % showMyTable(rows,columns)
            %

            disp(obj.T(k,col));
        end

        function myPause(obj,msg)
            % myPause キーを押して次へ進む
            %
            % myPause(message)
            %

            disp(msg);
            pause
        end

        function saveTable(obj,varargin)
            % saveTable 単語帳を保存
            % 
            % saveTable(savePath)
            %

            savePath = pwd;
            if nargin > 1
                savePath = varargin{1}; % パスの指定が有る場合
            end

            try
                MemoryTable = obj.T;
                %eitanTable = sortrows(myMemoryTable,"word");
                [~,idx] = sort(upper(MemoryTable.word));
                MemoryTable = MemoryTable(idx,:);
                save(fullfile(savePath,obj.uName),"MemoryTable");
            catch ME
                error(ME.message)
            end
        end

    end

end