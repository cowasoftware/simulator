#pragma once


#define PROPERTY(type, name, defultValue)                                  \
                                                                           \
private:                                                                   \
    Q_PROPERTY(type name READ get_##name WRITE set_##name NOTIFY name##Changed)  \
                                                                           \
private:                                                                   \
    type m_##name = defultValue;                                           \
                                                                           \
public:                                                                    \
    void set_##name(const type &a)                                         \
    {                                                                      \
        if(a != m_##name)                                                  \
        {                                                                  \
            m_##name = a;                                                  \
            Q_EMIT name##Changed();                                          \
        }                                                                  \
    }                                                                      \
                                                                           \
public:                                                                    \
    type get_##name() const                                                      \
    {                                                                      \
        return m_##name;                                                   \
    }                                                                      \
                                                                           \
public:                                                                    \
Q_SIGNALS:                                                                 \
    void name##Changed();


#define READ_PROPERTY(type, name, defultValue)                                  \
                                                                           \
private:                                                                   \
    Q_PROPERTY(type name READ get_##name NOTIFY name##Changed)  \
                                                                           \
private:                                                                   \
    type m_##name = defultValue;                                           \
                                                                           \
public:                                                                    \
    void set_##name(const type &a)                                         \
    {                                                                      \
        if(a != m_##name)                                                  \
        {                                                                  \
            m_##name = a;                                                  \
            Q_EMIT name##Changed();                                          \
        }                                                                  \
    }                                                                      \
                                                                           \
public:                                                                    \
    type get_##name() const                                                      \
    {                                                                      \
        return m_##name;                                                   \
    }                                                                      \
                                                                           \
public:                                                                    \
Q_SIGNALS:                                                                 \
    void name##Changed();
