from flask import Flask, request, jsonify
from langchain_community.document_loaders import PyPDFLoader
from langchain_community.vectorstores import FAISS
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_openai.embeddings import OpenAIEmbeddings
from langchain_google_genai import ChatGoogleGenerativeAI, HarmBlockThreshold, HarmCategory
from langchain.chains import RetrievalQA
from dotenv import load_dotenv
import tiktoken
import os

load_dotenv()

app = Flask(__name__)


def tiktoken_len(text):
    tokenizer = tiktoken.get_encoding("cl100k_base")
    tokens = tokenizer.encode(text, disallowed_special=())
    return len(tokens)


@app.route('/', methods=['GET'])
def home():
    return "Welcome to MindMate API!"


@app.route('/chat', methods=['POST'])
def chat():
    data = request.json
    user_message = data.get('message')

    if not user_message:
        return jsonify({'error': 'No message provided'}), 400

    # Load or build the FAISS index
    index_path = "mindmate_faiss_index"

    if os.path.exists(index_path):
        embeddings = OpenAIEmbeddings()
        vectorstore = FAISS.load_local(
            index_path, embeddings, allow_dangerous_deserialization=True
        )
    else:
        loader = PyPDFLoader("resources/Anxiety-Help-Book-For-Teens.pdf")
        docs = loader.load()

        text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=300,
            chunk_overlap=50,
            length_function=tiktoken_len,
            separators=["\n\n", "\n"],
        )
        split_docs = text_splitter.split_documents(docs)

        embeddings = OpenAIEmbeddings()
        vectorstore = FAISS.from_documents(split_docs, embeddings)
        vectorstore.save_local(index_path)

    llm = ChatGoogleGenerativeAI(
        model="gemini-2.0-flash",
        temperature=0.7,
        max_output_tokens=300,
        safety_settings={
            HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT: HarmBlockThreshold.BLOCK_NONE,
        },
    )

    qa = RetrievalQA.from_chain_type(
        llm=llm,
        chain_type="stuff",
        retriever=vectorstore.as_retriever(search_kwargs={"k": 3}),
    )

    prompt = """You are MindMate, a warm and empathetic AI companion for teenagers aged 13-19.

Rules:
- Keep responses to 1-2 short sentences MAX, like a friend texting.
- Never write paragraphs or bullet points.
- Validate feelings first, advise only if asked.
- Use at most 1 emoji per message, only when it feels natural.
- Never diagnose or act as a therapist.
- Do not use '*' in your response.
- If the user seems in crisis, gently encourage them to call a helpline.
- Use the retrieved context to inform your response, but never quote it directly.

User message: """ + user_message

    result = qa.invoke({"query": prompt})
    return jsonify({"response": result["result"]})


if __name__ == '__main__':
    app.run(debug=True, port=5001)