import logging

def get_logger(level=logging.INFO):
    logger = logging.getLogger()
    if len(logger.handlers) > 0:
        logger.setLevel(level)
    else:
        logging.basicConfig(level=level)
    return logger